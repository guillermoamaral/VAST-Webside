Class {
	#name : 'PercentEncoder',
	#superclass : 'Object',
	#instVars : [
		'reserved'
	],
	#classVars : [
		'Current'
	],
	#category : 'WebsideApp'
}

{ #category : 'Not categorized' }
PercentEncoder class >> current [
	Current isNil ifTrue: [Current := self new].
	^Current
]

{ #category : 'Not categorized' }
PercentEncoder class >> decode: aString [
	^self current decode: aString
]

{ #category : 'Not categorized' }
PercentEncoder class >> encode: aString [
	^self current encode: aString
]

{ #category : 'Not categorized' }
PercentEncoder class >> new [
	^super new initialize
]

{ #category : 'Not categorized' }
PercentEncoder >> decode: aString [
	"
	PercentEncoder decode: 'this%20is%20AT+%40'
	"
	| reader raw |
	reader := aString readStream.
	raw := String streamContents: [:strm | 
		[reader atEnd] whileFalse: [| char |
			char := reader next.
			(reader position > 1 and: [char = $+]) ifTrue: [strm space] ifFalse: [| code |
				char = $%
					ifTrue: [
						code := reader next digitValue * 16 + reader next digitValue.
						char := Character codePoint: code].
				strm nextPut: char]]].
	^"String fromUTF8: " raw
]

{ #category : 'Not categorized' }
PercentEncoder >> encode: aString [
	"
	PercentEncoder encode: 'this is AT @'
	"
	^String streamContents: [:strm | 
		aString do: [:char | 
			((reserved includes: char) or: [char codePoint > 127])
				ifTrue: [
					char asUtf8String asByteArray do: [:byte | | hex |
						hex := byte printStringRadix: 16.
						strm nextPut: $%; nextPutAll: hex]]
				ifFalse: [strm nextPut: char]]]
]

{ #category : 'Not categorized' }
PercentEncoder >> initialize [
	super initialize.
	self initializeReserved
]

{ #category : 'Not categorized' }
PercentEncoder >> initializeReserved [
	reserved := ' ?:@&=+$#;%/\!'
]
