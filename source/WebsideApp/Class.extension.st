Extension {
	#name : 'Class'
}

{ #category : '*WebsideApp',
 #vaCategories : ['Not categorized'] }
Class >> asWebsideJson [
	| definition |
	definition := self definitionString copyWithout: 10 asCharacter.
	^super asWebsideJson
		at: 'name' put: self name;
		at: 'definition' put: definition;
		at: 'superclass'
		put: (self superclass ifNotNil: [:c | c name]);
		at: 'comment' put: self comment;
		at: 'variable' put: self isVariable;
		at: 'project' put: nil;
		yourself
]
