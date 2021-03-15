Class {
	#name : 'MatchAlgorithm',
	#superclass : 'Object',
	#instVars : [
		'string',
		'pattern',
		'start',
		'stop',
		'tokens',
		'failure',
		'ranges'
	],
	#category : 'WebsideApp'
}

{ #category : 'Not categorized' }
MatchAlgorithm class >> new [
	^super new initialize
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
MatchAlgorithm >> failBecause: aString [
	failure := aString
]

{ #category : 'Not categorized' }
MatchAlgorithm >> failure [
	^failure
]

{ #category : 'Not categorized' }
MatchAlgorithm >> hasMatched [
	^failure isNil and: [tokens isEmpty]
]

{ #category : 'Not categorized' }
MatchAlgorithm >> hasTokens [
	^failure isNil and: [tokens notEmpty]
]

{ #category : 'Not categorized' }
MatchAlgorithm >> index: anInteger [
	start := anInteger
]

{ #category : 'Not categorized' }
MatchAlgorithm >> initialize [
	super initialize.
	start := 1
]

{ #category : 'Not categorized' }
MatchAlgorithm >> matchFirstStar [
	| range |
	range := string start @ nil.
	ranges add: tokens first -> range.
	tokens removeFirst.
	self hasTokens
		ifTrue: [tokens first matchFirstAfterStartOn: self]
		ifFalse: [
			range y: string stop.
			string stop: string start - 1]
]

{ #category : 'Not categorized' }
MatchAlgorithm >> matchFirstToken [
	| token min match save |
	token := tokens first.
	min := token length.
	match := false.
	save := string start.
	[
		string length >= min and: [
			match := string beginsWith: token.
			match not]]
		whileTrue: [string start: string start + 1].
	match
		ifTrue: [
			ranges add: token -> (string start @ (string start + min - 1)).
			string start: string start + token length.
			tokens removeFirst]
		ifFalse: [
			tokens size = 1 ifTrue: [
				string start: save.
				^self privateMatchLastToken].
			self
				failBecause: token asString , ' not present at position '
					, string start printString]
]

{ #category : 'Not categorized' }
MatchAlgorithm >> matchFirstTokenAfterStar [
	| token i |
	token := tokens first.
	i := string indexOf: token.
	i = 0
		ifTrue: [
			self
				failBecause: token asString , ' not present in inteval ['
					, string start printString
					, ', '
					, string stop printString]
		ifFalse: [
			ranges last value y: i - 1.
			ranges add: token -> (i @ (i + token length - 1)).
			string start: i + token length.
			tokens removeFirst]
]

{ #category : 'Not categorized' }
MatchAlgorithm >> matchLastToken [
	tokens size = 1
		ifTrue: [self matchFirstToken]
		ifFalse: [self privateMatchLastToken]
]

{ #category : 'Not categorized' }
MatchAlgorithm >> matchNextToken [
	tokens first matchFirstOn: self
]

{ #category : 'Not categorized' }
MatchAlgorithm >> matchRange [
	| sorted |
	sorted := (ranges collect: [:r | r value]) select: [:p | p x <= p y].
	sorted := sorted asSortedCollection: [:p :q | p x < q x].
	^sorted notEmpty ifTrue: [sorted first x @ sorted last y]
]

{ #category : 'Not categorized' }
MatchAlgorithm >> pattern: aStringPattern [
	pattern := aStringPattern
]

{ #category : 'Not categorized' }
MatchAlgorithm >> privateMatchLastToken [
	| token min match |
	token := tokens last.
	min := token length.
	match := false.
	[
		string length >= min and: [
			match := string endsWith: token.
			match not]]
		whileTrue: [string stop: string stop - 1].
	match
		ifTrue: [
			ranges add: token -> (string stop - min + 1 @ string stop).
			string stop: string stop - token length.
			tokens removeLast]
		ifFalse: [
			self
				failBecause: token asString , ' not present at position '
					, (string stop - token length + 1) printString]
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
MatchAlgorithm >> reset [
	| end |
	failure := nil.
	tokens := pattern tokens.
	string start: start.
	end := stop notNil ifTrue: [stop] ifFalse: [string string size].
	string stop: end.
	ranges := OrderedCollection new: tokens size
]

{ #category : 'Not categorized' }
MatchAlgorithm >> run [
	self reset.
	tokens isEmpty ifTrue: [^self].
	tokens last matchLastOn: self.
	[self hasTokens] whileTrue: [self matchNextToken]
]

{ #category : 'Not categorized' }
MatchAlgorithm >> string: aString [
	string := MatchToken on: aString from: 1 to: aString size
]
