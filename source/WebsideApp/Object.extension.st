Extension {
	#name : 'Object'
}

{ #category : '*WebsideApp',
 #vaCategories : ['Not categorized'] }
Object >> asWebsideJson [
	^NeoJSONObject new
		at: 'class' put: self class name;
		at: 'indexable' put: self class isVariable;
		at: 'size'
		put: (self class isVariable ifTrue: [self size] ifFalse: [0]);
		at: 'printString' put: self printString;
		yourself
]
