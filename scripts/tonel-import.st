| loader path |
path := (CfsPath named: 'C:\Users\guillermo.amaral\OneDrive - Quorum Business Solutions\Gamaral\Webside\servers\vast\VAST-Webside').
loader := TonelLoader readFromPath: path.
loader
	beUnattended;
	useGitVersion;
	resolveToLatestConfigMaps.
loader loadAllMapsWithRequiredMaps.