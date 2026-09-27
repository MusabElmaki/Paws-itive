"""Package the active app, backend, tests, docs and archived source without caches/secrets."""
from pathlib import Path
import os
import zipfile

root = Path(__file__).resolve().parents[1]
output = root / 'artifacts' / 'utm-pawsitive-source.zip'
output.parent.mkdir(exist_ok=True)
folders = ['lib', 'test', 'functions', 'android', 'ios', 'linux', 'windows', 'macos',
           'web', 'assets', 'public', 'docs', 'archive', 'tools']
excluded = {'node_modules', 'build', '.gradle', '.dart_tool', 'ephemeral', '.symlinks',
            'Pods', 'DerivedData', '.git', '.firebase', '__pycache__'}
excluded_files = {'local.properties', 'key.properties', 'Generated.xcconfig',
                  'flutter_export_environment.sh', '.DS_Store'}
files = [root / name for name in ['README.md', 'pubspec.yaml', 'pubspec.lock',
         'analysis_options.yaml', 'firebase.json', 'firestore.rules', 'storage.rules',
         'firestore.indexes.json', '.firebaserc', '.gitignore', '.metadata']]
for folder in folders:
    for directory, directories, names in os.walk(root / folder, followlinks=False):
        directories[:] = [d for d in directories if d not in excluded and not (Path(directory) / d).is_symlink()]
        for name in names:
            path = Path(directory) / name
            if (path.is_symlink() or name in excluded_files or name.startswith(('.env', '.secret'))
                    or path.suffix in {'.log', '.jks', '.keystore', '.pyc'}):
                continue
            files.append(path)
with zipfile.ZipFile(output, 'w', zipfile.ZIP_DEFLATED) as archive:
    for path in sorted(set(files)):
        if path.is_file():
            archive.write(path, path.relative_to(root))
    assert archive.testzip() is None
print(f'{output} ({output.stat().st_size:,} bytes)')
