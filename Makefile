XCODEBUILD := xcodebuild
BUILD_FLAGS = -scheme $(SCHEME) -destination $(DESTINATION)

SCHEME ?= $(TARGET)-$(PLATFORM)
TARGET ?= Kickstarter-Framework
PLATFORM ?= iOS
OS ?= 9.3
RELEASE ?= beta
BRANCH ?= master
DIST_BRANCH = $(RELEASE)-dist

ifeq ($(PLATFORM),iOS)
	DESTINATION ?= 'platform=iOS Simulator,name=iPhone 6,OS=9.3'
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
	PLATFORM=iOS "$(MAKE)" test
	PLATFORM=iOS TARGET=Library "$(MAKE)" test

test: bootstrap
	$(XCODEBUILD) test $(BUILD_FLAGS) $(XCPRETTY)

clean:
	$(XCODEBUILD) clean $(BUILD_FLAGS) $(XCPRETTY)

dependencies: submodules configs secrets

bootstrap: hooks dependencies
	brew update || brew update
	brew unlink swiftlint || true
	brew install swiftlint
	brew link --overwrite swiftlint

submodules:
	git submodule sync --recursive || true
	git submodule update --init --recursive || true

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

lint:
	swiftlint lint --reporter json

strings:
	cat Frameworks/ios-ksapi/Frameworks/native-secrets/ios/Secrets.swift bin/strings.swift | swift -

secrets:
	-@rm -rf Frameworks/ios-ksapi/Frameworks/native-secrets
	-@git clone https://github.com/kickstarter/native-secrets Frameworks/ios-ksapi/Frameworks/native-secrets 2>/dev/null || echo '(Skipping secrets.)'
	if [ ! -d Frameworks/ios-ksapi/Frameworks/native-secrets ]; \
	then \
		mkdir -p Frameworks/ios-ksapi/Frameworks/native-secrets/ios \
		&& cp -n Configs/Secrets.swift.example Frameworks/ios-ksapi/Frameworks/native-secrets/ios/Secrets.swift \
		|| true; \
	fi

.PHONY: test-all test clean dependencies submodules deploy lint secrets strings
