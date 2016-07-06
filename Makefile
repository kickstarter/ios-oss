XCODEBUILD := xcodebuild
BUILD_FLAGS = -scheme $(SCHEME) -destination $(DESTINATION)

SCHEME ?= $(TARGET)-$(PLATFORM)
TARGET ?= Kickstarter-Framework
PLATFORM ?= iOS
RELEASE ?= beta
BRANCH ?= master
DIST_BRANCH = $(RELEASE)-dist

ifeq ($(PLATFORM),iOS)
	DESTINATION ?= 'platform=iOS Simulator,name=iPhone 6'
endif
ifeq ($(PLATFORM),tvOS)
	DESTINATION ?= 'platform=tvOS Simulator,name=Apple TV 1080p'
endif

XCPRETTY :=
ifneq ($(CIRCLE_ARTIFACTS),)
	XCPRETTY += | tee $${CIRCLE_ARTIFACTS}/xcode_raw_$(SCHEME).log
endif
ifneq ($(shell type -p xcpretty),)
	XCPRETTY += | xcpretty -c && exit $${PIPESTATUS[0]}
endif

build: dependencies
	$(XCODEBUILD) $(BUILD_FLAGS) $(XCPRETTY)

test-all:
	PLATFORM=iOS $(MAKE) test
	PLATFORM=iOS TARGET=Library $(MAKE) test
	PLATFORM=tvOS $(MAKE) test
	PLATFORM=tvOS TARGET=Library $(MAKE) test

test: build
	$(XCODEBUILD) test $(BUILD_FLAGS) $(XCPRETTY)

clean:
	$(XCODEBUILD) clean $(BUILD_FLAGS) $(XCPRETTY)

dependencies: submodules configs

bootstrap: hooks
	brew update
	brew unlink swiftlint || true
	brew install swiftlint
	brew link swiftlint

submodules:
	git submodule sync --recursive
	git submodule update --init --recursive

configs = $(basename $(wildcard Kickstarter-iOS/Configs/*.example))
$(configs):
	cp $@.example $@

configs: $(configs)

hooks = $(addprefix .git/,$(wildcard hooks/*))
$(hooks):
	@test -d .git/hooks && ln -fnsv $(patsubst .git/%,$(PWD)/%,$@) $@ \
		|| echo "skipping git hook installation: .git/hooks does not exist" >&2 1>/dev/null

hooks: $(hooks)

deploy:
	@if test "$(RELEASE)" != "beta" && test "$(RELEASE)" != "itunes"; \
	then \
		echo "RELEASE must be 'beta' or 'itunes'."; \
		exit 1; \
	fi
	@if test "$(RELEASE)" = "itunes" && test "$(BRANCH)" != "master"; \
	then \
		echo "BRANCH must be 'master' for iTunes releases."; \
		exit 1; \
	fi

	git fetch origin
	git branch -f $(DIST_BRANCH) origin/$(BRANCH)
	git push -f origin $(DIST_BRANCH)
	git branch -d $(DIST_BRANCH)

.PHONY: test-all test clean dependencies submodules deploy
