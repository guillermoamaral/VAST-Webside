Class {
	#name : 'StringPattern',
	#superclass : 'Object',
	#instVars : [
		'stream',
		'tokens'
	],
	#category : 'WebsideApp'
}

{ #category : 'Not categorized' }
StringPattern class >> on: aString [
	^self new on: aString
]

{ #category : 'Not categorized' }
StringPattern >> addStar [
	stream atEnd ifTrue: [^self].
	tokens add: StarToken current.
	stream next.
	[stream peek ifNil: [^self] ifNotNil: [:c | c isAsterisk]]
		whileTrue: [stream next]
]

{ #category : 'Not categorized' }
StringPattern >> addToken [
	| star pos end token |
	star := false.
	pos := stream position + 1.
	[stream atEnd or: [star := stream next isAsterisk]] whileFalse.
	star ifTrue: [stream skip: -1].
	end := stream position.
	pos <= end ifTrue: [
		token := MatchToken on: stream collection from: pos to: end.
		tokens add: token]
]

{ #category : 'Not categorized' }
StringPattern >> input [
	^stream contents
]

{ #category : 'Not categorized' }
StringPattern >> match: aString [
	^self match: aString index: 1
]

{ #category : 'Not categorized' }
StringPattern >> match: aString index: anInteger [
	^self match: aString index: anInteger ifAbsent: nil
]

{ #category : 'Not categorized' }
StringPattern >> match: aString index: anInteger ifAbsent: aBlock [
	| algorithm |
	algorithm := MatchAlgorithm new
		pattern: self;
		string: aString;
		index: anInteger.
	algorithm run.
	algorithm hasMatched ifTrue: [^algorithm matchRange].
	^aBlock notNil ifTrue: [
		aBlock arity = 0
			ifTrue: [aBlock value]
			ifFalse: [aBlock evaluateWith: algorithm failure]]
]

{ #category : 'Not categorized' }
StringPattern >> matches: aString [
	| range |
	range := self match: aString.
	^range notNil and: [range x = 1 and: [range y = aString size]]
]

{ #category : 'Not categorized' }
StringPattern >> on: aString [
	stream := aString readStream.
	tokens := OrderedCollection new.
	self scan
]

{ #category : 'Not categorized' }
StringPattern >> printOn: aStream [
	tokens do: [:t | t printOn: aStream]
]

{ #category : 'Not categorized' }
StringPattern >> scan [
	[stream atEnd] whileFalse: [self addToken; addStar]
]

{ #category : 'Not categorized' }
StringPattern >> tokens [
	^tokens copy
]
