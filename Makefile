XCODEBUILD := xcodebuild
BUILD_FLAGS = -scheme $(SCHEME) -destination $(DESTINATION)

SCHEME ?= $(TARGET)-$(PLATFORM)
TARGET ?= Kickstarter
PLATFORM ?= iOS

ifeq ($(PLATFORM),iOS)
	DESTINATION ?= 'platform=iOS Simulator,OS=9.2,name=iPhone 6'
endif
ifeq ($(PLATFORM),tvOS)
	DESTINATION ?= 'platform=tvOS Simulator,OS=9.1,name=Apple TV 1080p'
endif

XCPRETTY :=
ifneq ($(CIRCLE_ARTIFACTS),)
	XCPRETTY += | tee $${CIRCLE_ARTIFACTS}/xcode_raw.log
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

submodules:
	git submodule sync --recursive
	git submodule update --init --recursive

configs = $(basename $(wildcard Kickstarter-iOS/Configs/*.example))
$(configs):
	cp $@.example $@

configs: $(configs)

.PHONY: test-all test clean dependencies submodules
