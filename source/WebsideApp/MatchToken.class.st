Class {
	#name : 'MatchToken',
	#superclass : 'Object',
	#instVars : [
		'string',
		'start',
		'stop'
	],
	#category : 'WebsideApp'
}

{ #category : 'Not categorized' }
MatchToken class >> on: aString from: start to: stop [
	^self new
		string: aString;
		start: start;
		stop: stop
]

{ #category : 'Not categorized' }
MatchToken >> asString [
	^string copyFrom: start to: stop
]

{ #category : 'Not categorized' }
MatchToken >> at: i [
	^string at: i
]

{ #category : 'Not categorized' }
MatchToken >> beginsWith: aMatchToken [
	self length >= aMatchToken length ifFalse: [^false].
	aMatchToken start to: aMatchToken stop do: [:i | | char |
		char := aMatchToken at: i.
		((self at: start + i - 1) = char or: [char isQuestionMark]) ifFalse: [^false]].
	^true

]

{ #category : 'Not categorized' }
MatchToken >> endsWith: aMatchToken [
	| end |
	self length >= aMatchToken length ifFalse: [^false].
	end := aMatchToken stop.
	end to: aMatchToken start by: -1 do: [:i | | char |
		char := aMatchToken at: i.
		((self at: stop - end + i) = char or: [char isQuestionMark]) ifFalse: [^false]].
	^true
]

{ #category : 'Not categorized' }
MatchToken >> indexOf: aMatchToken [
	^string indexOfString: aMatchToken asString from: start to: stop
]

{ #category : 'Not categorized' }
MatchToken >> length [
	^stop - start + 1
]

{ #category : 'Not categorized' }
MatchToken >> matchFirstAfterStartOn: aMatchAlgorithm [
	aMatchAlgorithm matchFirstTokenAfterStar
]

{ #category : 'Not categorized' }
MatchToken >> matchFirstOn: aMatchAlgorithm [
	aMatchAlgorithm matchFirstToken
]

{ #category : 'Not categorized' }
MatchToken >> matchLastOn: aMatchAlgorithm [
	aMatchAlgorithm matchLastToken
]

{ #category : 'Not categorized' }
MatchToken >> printOn: aStream [
	start to: stop do: [:i | aStream nextPut: (string at: i)]
]

{ #category : 'Not categorized' }
MatchToken >> start [
	^start
]

{ #category : 'Not categorized' }
MatchToken >> start: anInteger [
	start := anInteger
]

{ #category : 'Not categorized' }
MatchToken >> stop [
	^stop
]

{ #category : 'Not categorized' }
MatchToken >> stop: anInteger [
	stop := anInteger
]

{ #category : 'Not categorized' }
MatchToken >> string [
	^string
]

{ #category : 'Not categorized' }
MatchToken >> string: aString [
	string := aString
]
