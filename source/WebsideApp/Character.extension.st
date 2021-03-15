Extension {
	#name : 'Character'
}

{ #category : '*WebsideApp',
 #vaCategories : ['Not categorized'] }
Character >> isAsterisk [
	^self value = 42
]

{ #category : '*WebsideApp',
 #vaCategories : ['Not categorized'] }
Character >> isQuestionMark [
	^self value = 63
]
