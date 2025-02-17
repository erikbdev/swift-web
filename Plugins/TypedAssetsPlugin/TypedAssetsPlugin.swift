import PackagePlugin

@main
struct TypedAssetsPlugin: BuildToolPlugin {
  func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
    Diagnostics.remark("Running build tool [\(Self.self)]")
    guard let sourceModule = target.sourceModule else {
      Diagnostics.error("Not a source module")
      return []
    }

    let resources = sourceModule.sourceFiles.filter({ $0.type == .resource })
    guard !resources.isEmpty else {
      Diagnostics.warning("No resources found")
      return []
    }

    let resourcesInput = resources.flatMap { ["--input", $0.url.path()] }

    let outputPath = context.pluginWorkDirectoryURL.appending(component: "Generated\(target.name).swift", directoryHint: .notDirectory)
    return try [
      .prebuildCommand(
        displayName: "Running Static Asset Gen",
        executable: context.tool(named: "TypedAssetsCLI").url,
        arguments: resourcesInput + [
          "--output", outputPath.path(),
        ],
        outputFilesDirectory: context.pluginWorkDirectoryURL
      )
    ]
  }
}
