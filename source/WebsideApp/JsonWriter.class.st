Class {
	#name : 'JsonWriter',
	#superclass : 'Object',
	#instVars : [
		'stream',
		'indent',
		'visited'
	],
	#category : 'WebsideApp'
}

{ #category : 'Not categorized' }
JsonWriter class >> jsonObjectFrom: anObject [
	^self new jsonObjectFrom: anObject
]

{ #category : 'Not categorized' }
JsonWriter class >> new [
	^super new initialize
]

{ #category : 'Not categorized' }
JsonWriter class >> on: aStream [
	^self new on: aStream
]

{ #category : 'Not categorized' }
JsonWriter class >> write: anObject [
	^String streamContents: [:s | self write: anObject on: s]
]

{ #category : 'Not categorized' }
JsonWriter class >> write: anObject on: aStream [
	^self new on: aStream; write: anObject
]

{ #category : 'Not categorized' }
JsonWriter class >> write: anObject on: aStream indent: anInteger [
	^self new
		on: aStream;
		indent: anInteger;
		write: anObject
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
JsonWriter >> codeForChar: ch [
	| i code |
	('\"/' includes: ch) ifTrue: [^String with: $\ with: ch].
	ch codePoint = 8 ifTrue: [^'\b'].
	ch codePoint = 12 ifTrue: [^'\f'].
	ch codePoint = 10 ifTrue: [^'\n'].
	ch codePoint = 13 ifTrue: [^'\r'].
	ch codePoint = 9 ifTrue: [^'\t'].
	i := ch codePoint.
	i < 16r20 ifTrue: [
		code := i printPaddedWith: $0 to: 2 base: 16.
		^'\u00' , code].
	^i < 128 ifTrue: [ch] ifFalse: [ch "utf8" asString]
]

{ #category : 'Not categorized' }
JsonWriter >> contents [
	^stream contents
]

{ #category : 'Not categorized' }
JsonWriter >> cr [
	stream cr.
	indent timesRepeat: [stream tab]
]

{ #category : 'Not categorized' }
JsonWriter >> crtab [
	self cr; tab
]

{ #category : 'Not categorized' }
JsonWriter >> indent: anInteger [
	indent := anInteger.
	stream tab: indent
]

{ #category : 'Not categorized' }
JsonWriter >> initialize [
	super initialize.
	indent := 0
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
JsonWriter >> isBasic: anObject [
	anObject isNil ifTrue: [^true].
	anObject isNumber ifTrue: [^true].
	anObject isString ifTrue: [^true].
	anObject isBoolean ifTrue: [^true].
	anObject class == Date ifTrue: [^true].
	anObject class == DateAndTime ifTrue: [^true].
	^false
]

{ #category : 'Not categorized' }
JsonWriter >> nextWrite: aString [
	aString isCharacter ifTrue: [stream nextPut: aString] ifFalse: [
		stream nextPutAll: aString]
]

{ #category : 'Not categorized' }
JsonWriter >> on: aStream [
	stream := aStream.
	indent := 0
]

{ #category : 'Not categorized' }
JsonWriter >> reset [
	stream reset.
	indent := 0.
	visited := nil
]

{ #category : 'Not categorized' }
JsonWriter >> return [
	indent := indent - 1.
	self cr
]

{ #category : 'Not categorized' }
JsonWriter >> space [
	stream space
]

{ #category : 'Not categorized' }
JsonWriter >> tab [
	indent := indent + 1.
	stream tab
]

{ #category : 'Not categorized' }
JsonWriter >> write: anObject [
	visited isNil ifTrue: [visited := IdentitySet new].
	anObject isNil ifTrue: [^self writeNull].
	anObject isNumber ifTrue: [^self writeNumber: anObject].
	anObject isString ifTrue: [^self writeString: anObject].
	anObject isBoolean ifTrue: [^self writeBoolean: anObject].
	anObject class == Date ifTrue: [^self writeDate: anObject].
	anObject class == DateAndTime ifTrue: [^self writeTimestamp: anObject].
	(visited includes: anObject) ifTrue: [^self writeVisitedObject: anObject].
	visited add: anObject.
	[
		anObject isDictionary ifTrue: [^self writeDictionary: anObject].
		anObject isArray ifTrue: [^self writeArray: anObject].
		anObject isCollection ifTrue: [^self writeArray: anObject asArray].
		self writeObject: anObject]
		ensure: [visited remove: anObject]
]

{ #category : 'Not categorized' }
JsonWriter >> write: anObject on: aStream [
	self on: aStream; reset; write: anObject
]

{ #category : 'Not categorized' }
JsonWriter >> writeArray: anArray [
	self writeOperator: $[.
	anArray notEmpty ifTrue: [
		self crtab.
		anArray
			do: [:object | self write: object]
			separatedBy: [self writeOperator: $,; cr].
		self return].
	self writeOperator: $]
]

{ #category : 'Not categorized' }
JsonWriter >> writeBoolean: aBoolean [
	self nextWrite: aBoolean printString
]

{ #category : 'Not categorized' }
JsonWriter >> writeDate: aDate [
	self writeOperator: $".
	stream nextPutAll: (aDate stsFormattedUsing:  '%Y-%m-%d').
	self writeOperator: $"
]

{ #category : 'Not categorized' }
JsonWriter >> writeDictionary: aDictionary [
	| keys |
	self writeOperator: ${.
	aDictionary keys size > 1 ifTrue: [self crtab].
	keys := aDictionary keys.
	keys
		do: [:key | | value |
			value := aDictionary at: key.
			self
				writeKey: key;
				writeOperator: $:;
				space;
				write: value]
		separatedBy: [self writeOperator: $,; cr].
	aDictionary keys size > 1 ifTrue: [self return].
	self writeOperator: $}
]

{ #category : 'Not categorized' }
JsonWriter >> writeKey: aString [
	self writeString: aString
]

{ #category : 'Not categorized' }
JsonWriter >> writeMemory: anExternalMemory [
	self writeArray: anExternalMemory bytes
]

{ #category : 'Not categorized' }
JsonWriter >> writeNull [
	self nextWrite: 'null'
]

{ #category : 'Not categorized' }
JsonWriter >> writeNumber: aNumber [
	| number |
	aNumber isNaN ifTrue: [^self write: aNumber asString].
	aNumber isInf ifTrue: [^self write: aNumber asString].
	number := aNumber isFraction ifTrue: [aNumber asFloat] ifFalse: [aNumber].
	self nextWrite: number storeString
]

{ #category : 'Not categorized' }
JsonWriter >> writeObject: anObject [
	| json |
	json := self jsonObjectFrom: anObject.
	self write: json
]

{ #category : 'Not categorized' }
JsonWriter >> writeOperator: aCharacter [
	self nextWrite: aCharacter
]

{ #category : 'Not categorized' }
JsonWriter >> writeString: aString [
	self writeOperator: $".
	aString do: [:ch | | code |
		code := self codeForChar: ch.
		self nextWrite: code].
	self writeOperator: $"
]

{ #category : 'Not categorized' }
JsonWriter >> writeTimestamp: aDateAndTime [

	stream nextPut: $".
	stream nextPutAll: aDateAndTime sstHTTPDateString.
	stream nextPut: $"
]

{ #category : 'Not categorized' }
JsonWriter >> writeVisitedObject: anObject [
	| d |
	self error: 'Recursive'.
	d := Dictionary new.
	d at: 'Class' put: anObject class name.
	d at: 'Already Visited' put: true.
	anObject class allInstVarNames do: [:key | | ivar |
		ivar := anObject instVarNamed: key.
		(self isBasic: ivar) ifTrue: [ivar d at: key put: ivar]].
	self writeDictionary: d
]
