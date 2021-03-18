Class {
	#name : 'URLTemplate',
	#superclass : 'Object',
	#instVars : [
		'raw',
		'pattern',
		'parameters',
		'sample',
		'description'
	],
	#category : 'WebsideApp'
}

{ #category : 'Not categorized' }
URLTemplate class >> on: aString [
	^self new on: aString
]

{ #category : 'Not categorized' }
URLTemplate >> = anObject [
	^anObject class == self class and: [pattern = anObject pattern]
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
URLTemplate >> argumentsFrom: anURL [
	| arguments parts uri |
	arguments := Dictionary new.
	uri := self trimSlashesFrom: anURL relativeUri.
	parts := $/ split: uri.
	parameters keysAndValuesDo: [:i :param | | value |
		value := parts at: i ifAbsent: [].
		arguments at: param put: value].
	^arguments
]

{ #category : 'Not categorized' }
URLTemplate >> description [
	^description
]

{ #category : 'Not categorized' }
URLTemplate >> description: aString [
	description := aString
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
URLTemplate >> hasDescription [
	^description size > 0
]

{ #category : 'Not categorized' }
URLTemplate >> hash [
	^pattern hash

]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
URLTemplate >> initializeParamenters [
	| spec segments |
	parameters := Dictionary new.
	spec := self trimSlashesFrom: raw.
	segments := $/ split: spec.
	segments keysAndValuesDo: [:i :segment | 
		segment first = ${
			ifTrue: [parameters at: i put: segment allButFirst allButLast]]
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
URLTemplate >> initializePattern [
	| uri |
	uri := sample copy.
	parameters keysDo: [:i | uri segmentAt: i put: '*'].
	pattern := String streamContents: [:strm |
		uri segments do: [:s | strm nextPutAll: '\/'. s = '*' ifTrue: [strm nextPutAll: '[^/]+'] ifFalse: [strm nextPutAll: s]]]
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
URLTemplate >> initializeSample [
	| uri |
	uri := raw reject: [:c | c = ${ or: [c = $}]].
	sample := uri asURL.
	parameters keysAndValuesDo: [:i :s | sample segmentAt: (sample segments indexOf: s) put: i printString]
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
URLTemplate >> matches: anURL [
	(anURL relativeUri matchesRegex: pattern) ifFalse: [^false].
	^(raw last = $*) or: [sample segments size + 1 = anURL segments size]
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
URLTemplate >> on: aString [
	raw := aString.
	self initializeParamenters; initializeSample; initializePattern
]

{ #category : 'Not categorized' }
URLTemplate >> parameters [
	^parameters asArray
]

{ #category : 'Not categorized' }
URLTemplate >> pattern [
	^pattern
]

{ #category : 'Not categorized' }
URLTemplate >> printOn: aStream [
	aStream nextPutAll: raw
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
URLTemplate >> trimSlashesFrom: aString [
	| string |
	string := aString first = $/
		ifTrue: [aString allButFirst]
		ifFalse: [aString].
	string last = $/ ifTrue: [string := string allButLast].
	^string
]
