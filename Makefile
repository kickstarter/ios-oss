XCODEBUILD := xcodebuild
BUILD_FLAGS = -scheme $(SCHEME) -destination $(DESTINATION)

SCHEME ?= $(TARGET)-$(PLATFORM)
TARGET ?= Kickstarter-Framework
PLATFORM ?= iOS
RELEASE ?= itunes
IOS_VERSION ?= 12.1
IPHONE_NAME ?= iPhone 8
BRANCH ?= master
DIST_BRANCH = $(RELEASE)-dist
FABRIC_SDK_VERSION ?= 3.10.5
FABRIC_SDK_URL ?= https://s3.amazonaws.com/kits-crashlytics-com/ios/com.twitter.crashlytics.ios/INSERT_SDK_VERSION/com.crashlytics.ios-manual.zip
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

dependencies: carthage-bootstrap configs secrets fabric

bootstrap: hooks dependencies

carthage-bootstrap:
	set -o pipefail; bin/carthage.sh;

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
	@if test "$(RELEASE)" != "itunes"; \
	then \
		echo "RELEASE must be 'itunes'."; \
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

beta:
	@echo "Adding remotes..."
	@git remote add oss https://github.com/kickstarter/ios-oss
	@git remote add private https://github.com/kickstarter/ios-private

	@echo "Deploying private/beta-dist-$(COMMIT)..."

	@git branch -f beta-dist-$(COMMIT)
	@git push -f private beta-dist-$(COMMIT)
	@git branch -d beta-dist-$(COMMIT)

	@echo "Deploy has been kicked off to CircleCI!"

sync:
	@echo "Syncing oss and private remotes..."

	@git checkout $(BRANCH)
	@git pull oss $(BRANCH)
	@git push private $(BRANCH)

	@echo "private and oss remotes are now synced!"

cleanup:
	@echo "Adding remotes..."
	@git remote add oss https://github.com/kickstarter/ios-oss
	@git remote add private https://github.com/kickstarter/ios-private

	@echo "Deleting temporary branch: $(CIRCLE_BRANCH)"

	@git push -d private $(CIRCLE_BRANCH)

strings:
	cp Frameworks/native-secrets/ios/Secrets.swift bin/StringsScript/Sources/StringsScriptCore
	./bin/strings-script "./Library/Strings.swift" "./Kickstarter-iOS/Locales"

secrets:
	-@rm -rf Frameworks/native-secrets
	-@git clone https://github.com/kickstarter/native-secrets Frameworks/native-secrets 2>/dev/null || echo '(Skipping secrets.)'
	if [ ! -d Frameworks/native-secrets ]; \
	then \
		mkdir -p Frameworks/native-secrets/ios \
		&& cp -n Configs/Secrets.swift.example Frameworks/native-secrets/ios/Secrets.swift \
		|| true; \
	fi

fabric:
	bin/download_framework.sh Fabric $(FABRIC_SDK_VERSION) $(FABRIC_SDK_URL); \

.PHONY: test-all test clean dependencies submodules deploy lint secrets strings fabric
