import 'dart:async';

import 'package:flutter/material.dart';

import 'classes.dart';
import 'functions.dart'; //Разрабы дауны

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
	const MyApp({super.key});

	@override
	State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
	Future<List<DropdownMenuEntry>>? versions;
	final TextEditingController versionController = TextEditingController();
	Version? selectedVersion;
	String pathValue = 'C:/Games/Minecraft/Fumbles';

	@override
	void initState() {
		super.initState();
    versions = getManifest(pathValue);
	}

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'Fetch Data Example',
			theme: ThemeData(
				colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
			),
			home: Scaffold(
				appBar: AppBar(
					title: const Text('Fumbles Launcher Dev'),
				),
				body: Center(
					child: Column(
						mainAxisSize: MainAxisSize.min,
						children: [
							SizedBox(
								width: 450,
								child: TextFormField(
									initialValue: pathValue,
									validator: (value) {
										if (value == null || value.isEmpty) {
											return 'Please enter some text';
										}
										return null;
									},
									onChanged: (value) {
										setState(() {
											pathValue = value;
										});
									},
								),
							),
							
							const SizedBox(height: 20),
							
							FutureBuilder(
								future: versions,
								builder: (context, snapshot) {
									if (snapshot.hasData) {
										return DropdownMenu(
											width: 700,
											hintText: 'Version',
											dropdownMenuEntries: snapshot.data!,
											onSelected: (value) {
												setState(() {
													selectedVersion = value;
												});
												versionController.text = selectedVersion!.url;
											},
											helperText: selectedVersion?.url.toString(),
										);
									} else if (snapshot.hasError) {
										return Text('${snapshot.error}');
									}
									// By default, show a loading spinner.
									return const CircularProgressIndicator();
								},
							),
							
							const SizedBox(height: 20),
							
							ElevatedButton(
								onPressed: selectedVersion == null ? null : () async{
									var pathValueOrig = pathValue;
									
									var versionName = selectedVersion!.url.split('/').last;
									Package verPackage = await downloadVersionJson(selectedVersion!.url, versionName, pathValue, selectedVersion!.sha1);
									String libCP = await downloadLibraries(verPackage, pathValue);
									await downloadClient(verPackage, versionName, pathValue);
									await downloadAssets(verPackage, pathValue);
									launchMinecraft(pathValue, versionName, libCP);
									
									pathValue = pathValueOrig;
								},
								child: const Text('Download selected version')
							),
						],
					),
				),
			),
		);
	}
}
