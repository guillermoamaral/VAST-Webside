"
WebsideServer new
	port: 9003;
	baseUri: '/vast';
	start
"
Class {
	#name : 'WebsideServer',
	#superclass : 'Object',
	#instVars : [
		'server',
		'router',
		'baseUri',
		'port',
		'evaluations',
		'objects',
		'workspaces',
		'debuggres'
	],
	#category : 'WebsideApp'
}

{ #category : 'Not categorized' }
WebsideServer class >> new [
	 ^super new initialize
]

{ #category : 'Not categorized' }
WebsideServer >> baseUri [
	^ baseUri
]

{ #category : 'Not categorized' }
WebsideServer >> baseUri: aString [
	baseUri := aString
]

{ #category : 'Not categorized' }
WebsideServer >> defaultBaseUri [
	^ '/vast'
]

{ #category : 'Not categorized' }
WebsideServer >> defaultPort [
	^ 9003
]

{ #category : 'Not categorized' }
WebsideServer >> handleRequest: request with: response [
	| result error |
	result := [router route: request] on: Error do: [:e | error := e].
	error notNil
		ifTrue: [
			response header status: SstHttpConstants::HttpInternalServerError.
			response contents: error description]
		ifFalse: 
			[(result isKindOf: SstCommunicationMessage)
				ifTrue: [
					response header: result header.
					response contents: result contents]
				ifFalse: [ | payload |
					payload := NeoJSONWriter toString: result.
					response header
						status: SstHttpConstants::HttpOk;
						contentType: 'application/json; charset=utf-8'.
					response contents: payload]].
	response header at: 'Access-Control-Allow-Origin' put: '*'.
	^response
]

{ #category : 'Not categorized' }
WebsideServer >> initialize [
	super initialize.
	port := self defaultPort.
	baseUri := self defaultBaseUri.
	router := HttpRequestRouter new.
	self initializeRoutes
]

{ #category : 'Not categorized' }
WebsideServer >> initializeChangesRoutes [
	router
		routeGET: '/changes' to: #changes;
		routePOST: '/changes' to: #addChange
]

{ #category : 'Not categorized' }
WebsideServer >> initializeCodeRoutes [
	router
		routeGET: '/dialect' to: #dialect;
		routeGET: '/packages' to: #packages;
		routeGET: '/packages/{name}' to: #package;
		routeGET: '/packages/{name}/classes' to: #packageClasses;
		routeGET: '/packages/{name}/methods' to: #packageMethods;
		routeGET: '/classes' to: #classes;
		routeGET: '/classes/{name}' to: #classDefinition;
		routeGET: '/classes/{name}/subclasses' to: #subclasses;
		routeGET: '/classes/{name}/variables' to: #variables;
		routeGET: '/classes/{name}/instance-variables'
			to: #instanceVariables;
		routeGET: '/classes/{name}/class-variables' to: #classVariables;
		routeGET: '/classes/{name}/categories' to: #categories;
		routeGET: '/classes/{name}/methods' to: #methods;
		routeGET: '/classes/{name}/methods/{selector}' to: #method;
		routeGET: '/methods' to: #methods
]

{ #category : 'Not categorized' }
WebsideServer >> initializeDebuggingRoutes [
	router
		routePOST: '/debuggers' to: #createDebugger;
		routeGET: '/debuggers/{id}/frames' to: #debuggerFrames;
		routeGET: '/debuggers/{id}/frames/{index}' to: #debuggerFrame;
		routeGET: '/debuggers/{id}/frames/{index}/bindings'
			to: #frameBindings;
		routePOST: '/debuggers/{id}/frames/{index}/stepover'
			to: #stepOverDebugger;
		routePOST: '/debuggers/{id}/frames/{index}/stepinto'
			to: #stepIntoDebugger;
		routePOST: '/debuggers/{id}/frames/{index}/restart'
			to: #restartDebugger;
		routePOST: '/debuggers/{id}/resume' to: #resumeDebugger;
		routePOST: '/debuggers/{id}/terminate' to: #terminateDebugger;
		routeDELETE: '/debuggers/{id}' to: #deleteDebugger
]

{ #category : 'Not categorized' }
WebsideServer >> initializeEvaluationRoutes [
	router
		routePOST: '/evaluations' to: #evaluateExpression;
		routeGET: '/evaluation/{id}' to: #evaluation
]

{ #category : 'Not categorized' }
WebsideServer >> initializeObjectsRoutes [
	router
		routeGET: '/objects' to: #pinnedObjects;
		routeGET: '/objects/{id}' to: #pinnedObject;
		routeDELETE: '/objects/{id}' to: #unpinObject;
		routeGET: '/objects/{id}/*' to: #pinnedObjectSlot
]

{ #category : 'Not categorized' }
WebsideServer >> initializeRoutes [
	router receiver: [WebsideAPI new server: self].
	self
		initializeCodeRoutes;
		initializeChangesRoutes;
		initializeEvaluationRoutes;
		initializeObjectsRoutes;
		initializeWorkspacesRoutes;
		initializeDebuggingRoutes
]

{ #category : 'Not categorized' }
WebsideServer >> initializeServer [
	| handler |
	handler := DirectedMessage
		receiver: [:request :response | self handleRequest: request with: response]
		selector: #value:value:.
	server := SstHttpServer new.
	server
		addHandlerUrl: 'http://localhost:', self port printString , self baseUri;
		requestHandler: handler
]

{ #category : 'Not categorized' }
WebsideServer >> initializeWorkspacesRoutes [
	router
		routePOST: '/workspaces' to: #createWorkspace;
		routeGET: '/workspaces' to: #workspaces;
		routeGET: '/workspaces/{id}' to: #workspaces;
		routeDELETE: '/workspaces/{id}' to: #deleteWorkspace
]

{ #category : 'Not categorized' }
WebsideServer >> port [
	^ port
]

{ #category : 'Not categorized' }
WebsideServer >> port: anInteger [
	port := anInteger
]

{ #category : 'Not categorized' }
WebsideServer >> start [
	self initializeServer.
	server startUp
]

{ #category : 'Not categorized' }
WebsideServer >> stop [
	server shutDown
]
