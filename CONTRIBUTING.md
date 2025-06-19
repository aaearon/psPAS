# Contributing

All contributions, whether comments, code or otherwise are welcomed and appreciated.

## psPAS Issues

If you find an error in `psPAS`, or have a question relating to the module, [log an issue][new-issue].

## Pull Requests

When submitting a Pull Request to psPAS, automated testing will run to ensure code quality and functionality.

### Testing Infrastructure

**Fork Contributors**: GitHub Actions workflow provides fork-friendly testing
- Automatically runs when you push changes to your fork
- Tests on Windows PowerShell 5.1 and PowerShell 7.x (Windows & Ubuntu)
- Executes complete test suite (1870+ tests across 205+ test files)
- No external setup required - completely self-contained
- Test results available as downloadable artifacts

**Main Repository**: AppVeyor handles production CI/CD
- Appveyor will increment the version number (there is no need to do this manually)
- The [`Pester`][pester-repo] tests for the module will run
- [Code Coverage][code-coverage] metrics for the module will be determined
- Once code is merged into the `master` branch, and all tests pass, the module is automatically published to the PowerShell Gallery and tagged as a Release on GitHub
  - No PR's should be submitted to the master branch; submitting to the Dev branch allows for required tests & documentation to be updated prior to any code release.

## Contributing Code

- Fork the repo.
- Push your changes to your fork.
  - **Automatic Testing**: GitHub Actions will automatically run the complete test suite when you push changes
  - **Test Results**: Check the Actions tab in your fork to view test results and download artifacts
  - **Local Testing**: Run tests locally using `pwsh.exe -File .\build\test.ps1`
- Write [good commit messages][commit]
- If no related issue exists already, open a [New Issue][new-issue] describing the problem being fixed or feature.
- [Update documentation](#updating-documentation) for the command as required.
- Submit a pull request to the [Dev Branch][dev-branch]
  - Keep pull requests limited to a single issue
  - Discussion, or necessary changes may be needed before merging the contribution.
  - Link the pull request to the related issue

### PowerShell Styleguide

Use the standard *Verb*-*Noun* convention, and only use approved verbs.

All Functions must have Comment Based Help.

[K&R (One True Brace Style variant)](https://github.com/PoshCode/PowerShellPracticeAndStyle/issues/81) preferred.

## Updating Documentation

Project documentation, help files, examples and all content of the [psPAS Site][pspas-site] is able to be updated.

The [Docs][pspas-docs] site content is generated from [these files][docs]

### Command Help

[Command Help][command-help] Markdown files are generated into the [psPAS Documentation][pspas-commands].

The files can be edited to correct any errors, or include any additional detail, examples or relevant information.

If changes have been made the the parameters of the related psPAS function, the `platyPS` module must be used to automatically update markdown files with changes to parameters and command syntax:

```powershell
#From the module root directory, run:
import-module platyPS
Update-MarkdownHelp -Path .\docs\collections\_commands\
```

#### External Help File

[Command Help][command-help] Markdown files are the source of truth for the `Get-Help` content of the module.

Changes to these markdown files must be reflected in the `Get-Help` content.

`platyPS` must be used to automatically generate the external help file:

```powershell
#From the module root directory, run:
import-module platyPS
New-ExternalHelp -Path .\docs\collections\_commands\ -OutputPath .\psPAS\en-US\psPAS-help.xml -Force
```

[commit]: http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
[OTBS]: https://github.com/PoshCode/PowerShellPracticeAndStyle/issues/81
[new-issue]: https://github.com/pspete/psPAS/issues/new
[dev-branch]: https://github.com/pspete/psPAS/tree/dev
[pester-repo]: https://github.com/pester/Pester
[code-coverage]: https://coveralls.io/github/pspete/psPAS
[pspas-site]: https://pspas.pspete.dev/
[command-help]: https://github.com/pspete/psPAS/tree/master/docs/collections/_commands
[pspas-commands]: https://pspas.pspete.dev/commands/
[docs]: https://github.com/pspete/psPAS/tree/master/docs/collections/_docs
[pspas-docs]: https://pspas.pspete.dev/docs/authentication/
[commands]: https://github.com/pspete/psPAS/blob/master/docs/collections/_pages/commands.md