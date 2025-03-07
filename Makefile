XCODEBUILD := xcodebuild
BUILD_FLAGS = -scheme $(SCHEME) -destination $(DESTINATION)

SCHEME ?= $(TARGET)-$(PLATFORM)
TARGET ?= Kickstarter-Framework
PLATFORM ?= iOS
RELEASE ?= itunes
# Keep simulator in sync with `Library/TestHelpers/TestCase.swift` and `.circleci/config.yml`
IOS_VERSION ?= 17.5
IPHONE_NAME ?= iPhone SE (3rd generation)
BRANCH ?= main
DIST_BRANCH = $(RELEASE)-dist
COMMIT ?= $(CIRCLE_SHA1)
CURRENT_BRANCH ?= $(CIRCLE_BRANCH)

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

dependencies: configs secrets

bootstrap: hooks dependencies

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
	@if test "$(RELEASE)" = "itunes" && test "$(BRANCH)" != "main"; \
	then \
		echo "BRANCH must be 'main' for iTunes releases."; \
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

	@echo "Deploying private/alpha-dist-$(CURRENT_BRANCH)-$(COMMIT)..."

	@git branch -f alpha-dist-$(CURRENT_BRANCH)-$(COMMIT)
	@git push -f private alpha-dist-$(CURRENT_BRANCH)-$(COMMIT)
	@git branch -d alpha-dist-$(CURRENT_BRANCH)-$(COMMIT)

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
	@git remote add oss git@github.com:kickstarter/ios-oss
	@git remote add private git@github.com:kickstarter/ios-private

	@echo "Deleting temporary branch: $(CIRCLE_BRANCH)"

	@git push -d private $(CIRCLE_BRANCH)

strings:
	cp Frameworks/native-secrets/ios/Secrets.swift bin/StringsScript/Sources/StringsScriptCore
	./bin/strings-script "./Library/Strings.swift" "./Kickstarter-iOS/Locales"

secrets:
	-@rm -rf Frameworks/native-secrets
	-@git clone git@github.com:kickstarter/native-secrets Frameworks/native-secrets 2>/dev/null || echo '(Skipping secrets.)'
	if [ ! -d Frameworks/native-secrets ]; \
	then \
		mkdir -p Frameworks/native-secrets/ios \
		&& cp -n Configs/Secrets.swift.example Frameworks/native-secrets/ios/Secrets.swift \
		|| true; \
	fi

.PHONY: test-all test clean dependencies submodules deploy secrets strings
