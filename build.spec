# -*- mode: python ; coding: utf-8 -*-
a = Analysis(
    ['structgen/cli.py'],
    pathex=[],
    binaries=[],
    datas=[('structgen/grammar.lark', 'structgen'), ('structgen/template.h', 'structgen')],
    hiddenimports=['jinja2', 'click', 'lark'],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludedimports=[],
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=None)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='structgen',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=True,
    disable_windowed_traceback=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
)