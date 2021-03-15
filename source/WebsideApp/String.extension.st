Extension {
	#name : 'String'
}

{ #category : '*WebsideApp',
 #vaCategories : ['Not categorized'] }
String >> asURL [
	^URL fromString: self
]

{ #category : '*WebsideApp',
 #vaCategories : ['Not categorized'] }
String >> indexOfString: aString from: start to: stop [
	| n limit base i |
	n := aString size.
	limit := stop - n.
	base := start - 1.
	i := 1.
	[
		base > limit ifTrue: [^0].
		i <= n]
		whileTrue: [
			i := (self at: base + i) = (aString at: i) ifTrue: [i + 1] ifFalse: [
				base := base + 1.
				1]].
	^i > 1 ifTrue: [base + 1] ifFalse: [0]


]
