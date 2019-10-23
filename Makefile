all: framework

WORKSPACE=Example/Batch-AtInternet-Dispatcher.xcworkspace
SIMULATOR='platform=iOS Simulator,name=iPhone X'

clean:
	set -o pipefail && xcodebuild clean -workspace $(WORKSPACE) -scheme Batch-AtInternet-Dispatcher | xcpretty

framework: clean
	set -o pipefail && xcodebuild build -workspace $(WORKSPACE) -scheme Batch-AtInternet-Dispatcher -destination generic/platform=iOS | xcpretty

test: clean
	set -o pipefail && xcodebuild test -workspace $(WORKSPACE) -scheme Batch-AtInternet-Dispatcher -destination $(SIMULATOR) | xcpretty

multi_test: clean
	set -o pipefail && xcodebuild test -workspace $(WORKSPACE) -scheme Batch-AtInternet-Dispatcher \
	-destination $(SIMULATOR) \
	-destination 'platform=iOS Simulator,name=iPhone 6,OS=8.4' \
	-destination 'platform=iOS Simulator,name=iPhone 6s,OS=9.3' \
	-destination 'platform=iOS Simulator,name=iPhone 5,OS=8.4' \
	-destination 'platform=iOS Simulator,name=iPhone 5,OS=9.3' \
	-destination 'platform=iOS Simulator,name=iPhone 5,OS=10.3.1' \
	| xcpretty

ci: test
