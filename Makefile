XCODEBUILD := xcodebuild
BUILD_FLAGS = -scheme $(SCHEME) -destination $(DESTINATION)

SCHEME ?= $(TARGET)-$(PLATFORM)
TARGET ?= Kickstarter-Framework
PLATFORM ?= iOS
RELEASE ?= beta
IOS_VERSION ?= 11.3
IPHONE_NAME ?= iPhone 8
BRANCH ?= master
DIST_BRANCH = $(RELEASE)-dist
OPENTOK_VERSION ?= 2.10.2
COMMIT ?= $(CIRCLE_SHA1)

ifeq ($(PLATFORM),iOS)
	DESTINATION ?= 'platform=iOS Simulator,name=$(IPHONE_NAME),OS=$(IOS_VERSION)'
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

dependencies: submodules configs secrets opentok

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
	@echo "Deploying private/$(BRANCH) to $(RELEASE)..."

	@git fetch oss
	@git fetch private

	@if test -n "`git rev-list private/$(BRANCH)..oss/$(BRANCH)`"; \
	then \
		echo "There are commits in oss/$(BRANCH) that are not in private/$(BRANCH). Please sync the remotes before deploying."; \
		exit 1; \
	fi
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

	@git branch -f $(DIST_BRANCH) private/$(BRANCH)
	@git push -f private $(DIST_BRANCH)
	@git branch -d $(DIST_BRANCH)

	@echo "Deploy has been kicked off to CircleCI!"

alpha:
	@echo "Adding remotes..."
	@git remote add oss https://github.com/kickstarter/ios-oss
	@git remote add private https://github.com/kickstarter/ios-private

	@echo "Deploying private/alpha-dist-$(COMMIT)..."

	@git branch -f alpha-dist-$(COMMIT)
	@git push -f private alpha-dist-$(COMMIT)
	@git branch -d alpha-dist-$(COMMIT)

	@echo "Deploy has been kicked off to CircleCI!"

sync:
	@echo "Syncing oss and private remotes..."

	@git checkout oss $(BRANCH)
	@git pull oss $(BRANCH)
	@git push private $(BRANCH)
	
	@echo "private and oss remotes are now synced!"

cleanup:
	@echo "Adding remotes..."
	@git remote add oss https://github.com/kickstarter/ios-oss
	@git remote add private https://github.com/kickstarter/ios-private

	@echo "Deleting temporary branch: $(CIRCLE_BRANCH)"

	@git push -d private $(CIRCLE_BRANCH)

lint:
	swiftlint lint --reporter json --strict

strings:
	cat Frameworks/native-secrets/ios/Secrets.swift bin/strings.swift \
		| xcrun -sdk macosx swift -

secrets:
	-@rm -rf Frameworks/native-secrets
	-@git clone https://github.com/kickstarter/native-secrets Frameworks/native-secrets 2>/dev/null || echo '(Skipping secrets.)'
	if [ ! -d Frameworks/native-secrets ]; \
	then \
		mkdir -p Frameworks/native-secrets/ios \
		&& cp -n Configs/Secrets.swift.example Frameworks/native-secrets/ios/Secrets.swift \
		|| true; \
	fi

VERSION_FILE = Frameworks/OpenTok/version
CURRENT_OPENTOK_VERSION = $(shell cat $(VERSION_FILE))
ifeq ($(CURRENT_OPENTOK_VERSION),)
	CURRENT_OPENTOK_VERSION = first
endif
opentok:
	@if [ $(OPENTOK_VERSION) != $(CURRENT_OPENTOK_VERSION) ]; \
	then \
		echo "Downloading OpenTok v$(OPENTOK_VERSION)"; \
		mkdir -p Frameworks/OpenTok; \
		curl -s -N -L https://tokbox.com/downloads/opentok-ios-sdk-$(OPENTOK_VERSION) \
		| tar -xz --strip 1 --directory Frameworks/OpenTok OpenTok-iOS-$(OPENTOK_VERSION)/OpenTok.framework \
		|| true; \
	fi
	@if [ -e Frameworks/OpenTok/OpenTok.framework ]; \
	then \
		echo "$(OPENTOK_VERSION)" > $(VERSION_FILE); \
	fi

.PHONY: test-all test clean dependencies submodules deploy lint secrets strings opentok
