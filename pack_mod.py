#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Skript zum Erstellen einer ZIP-Datei für Brotato-Mods.
Die ZIP-Datei hat die Struktur: mods-unpacked/[Projektordner]/...
"""

import os
import zipfile
import shutil
import argparse
from pathlib import Path


def create_mod_zip(source_dir=None, output_dir=None, project_name=None):
    """
    Erstellt eine ZIP-Datei für einen Mod.
    
    Args:
        source_dir: Quellverzeichnis (aktuelles Verzeichnis, wenn None)
        output_dir: Zielverzeichnis für die ZIP (aktuelles Verzeichnis, wenn None)
        project_name: Name des Projektordners (wird automatisch erkannt, wenn None)
    """
    # Aktuelles Verzeichnis als Quelle verwenden, falls nicht angegeben
    if source_dir is None:
        source_dir = Path.cwd()
    else:
        source_dir = Path(source_dir)
    
    # Projektordner-Name ermitteln
    if project_name is None:
        project_name = source_dir.name
    
    # Ausgabeverzeichnis bestimmen
    if output_dir is None:
        output_dir = source_dir.parent
    else:
        output_dir = Path(output_dir)
        output_dir.mkdir(parents=True, exist_ok=True)
    
    # ZIP-Dateiname
    zip_filename = f"{project_name}.zip"
    zip_path = output_dir / zip_filename
    
    print(f"Erstelle ZIP-Datei: {zip_path}")
    print(f"Quellverzeichnis: {source_dir}")
    print(f"Projektordner-Name: {project_name}")
    print(f"ZIP-Struktur: mods-unpacked/{project_name}/...")
    print()
    
    # Zu ignorierende Dateien/Ordner
    ignore_patterns = {
        '.git',
        '.gitignore',
        '__pycache__',
        '*.pyc',
        '.DS_Store',
        'Thumbs.db',
        'pack_mod.py',  # Das Skript selbst nicht einpacken
    }
    
    def should_ignore(path):
        """Prüft ob eine Datei/Ordner ignoriert werden soll"""
        path_str = str(path)
        name = path.name
        
        # Ignoriere versteckte Dateien, die mit . beginnen (außer .gd Dateien)
        if name.startswith('.') and not name.endswith('.gd'):
            return True
        
        # Prüfe Ignore-Patterns
        for pattern in ignore_patterns:
            if pattern in path_str or name == pattern or path.suffix == pattern:
                return True
        
        return False
    
    # ZIP-Datei erstellen
    files_added = 0
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        # Alle Dateien durchgehen
        for root, dirs, files in os.walk(source_dir):
            root_path = Path(root)
            
            # Verzeichnisse filtern
            dirs[:] = [d for d in dirs if not should_ignore(root_path / d)]
            
            for file in files:
                file_path = root_path / file
                
                # Datei ignorieren, falls nötig
                if should_ignore(file_path):
                    continue
                
                # Relativer Pfad innerhalb des Projektordners
                relative_path = file_path.relative_to(source_dir)
                
                # Pfad in der ZIP: mods-unpacked/[Projektordner]/[relative_path]
                zip_path_in_archive = f"mods-unpacked/{project_name}/{relative_path}"
                
                # Datei zur ZIP hinzufügen
                zipf.write(file_path, zip_path_in_archive)
                files_added += 1
                print(f"  + {relative_path}")
    
    print()
    print(f"✓ ZIP-Datei erfolgreich erstellt: {zip_path}")
    print(f"✓ {files_added} Dateien eingepackt")
    
    return zip_path


def copy_and_pack(source_zip, target_dir, new_project_name):
    """
    Kopiert eine ZIP-Datei in ein Zielverzeichnis und erstellt dort eine neue ZIP
    mit anderem Projektordnernamen.
    
    Args:
        source_zip: Pfad zur Quell-ZIP-Datei
        target_dir: Zielverzeichnis
        new_project_name: Neuer Projektordner-Name
    """
    source_zip = Path(source_zip)
    target_dir = Path(target_dir)
    
    if not source_zip.exists():
        print(f"Fehler: ZIP-Datei nicht gefunden: {source_zip}")
        return None
    
    print(f"Kopiere und packe um: {source_zip.name}")
    print(f"Neuer Projektordner-Name: {new_project_name}")
    print()
    
    # Temporäres Verzeichnis zum Entpacken
    temp_dir = target_dir / f"temp_{new_project_name}"
    temp_dir.mkdir(parents=True, exist_ok=True)
    
    try:
        # ZIP entpacken
        with zipfile.ZipFile(source_zip, 'r') as zipf:
            zipf.extractall(temp_dir)
        
        # Alten Projektordner finden (sollte mods-unpacked/[alt] sein)
        unpacked_dir = temp_dir / "mods-unpacked"
        if not unpacked_dir.exists():
            print("Fehler: Struktur 'mods-unpacked' nicht gefunden in ZIP")
            return None
        
        # Alle Projektordner finden
        project_dirs = list(unpacked_dir.iterdir())
        if not project_dirs:
            print("Fehler: Kein Projektordner in 'mods-unpacked' gefunden")
            return None
        
        # Ersten Projektordner umbenennen oder neuen erstellen
        old_project_dir = project_dirs[0]
        new_project_dir = unpacked_dir / new_project_name
        
        if old_project_dir != new_project_dir:
            if old_project_dir.is_dir():
                shutil.move(str(old_project_dir), str(new_project_dir))
            else:
                new_project_dir.mkdir(parents=True, exist_ok=True)
                shutil.copy2(str(old_project_dir), str(new_project_dir / old_project_dir.name))
        
        # Neue ZIP erstellen
        new_zip_path = create_mod_zip(
            source_dir=unpacked_dir.parent,
            output_dir=target_dir,
            project_name=new_project_name
        )
        
        return new_zip_path
    
    finally:
        # Temporäres Verzeichnis löschen
        if temp_dir.exists():
            shutil.rmtree(temp_dir)


def main():
    parser = argparse.ArgumentParser(
        description='Erstellt eine ZIP-Datei für Brotato-Mods mit der Struktur mods-unpacked/[Projektordner]/...'
    )
    parser.add_argument(
        '--output', '-o',
        type=str,
        help='Zielverzeichnis für die ZIP-Datei (Standard: übergeordnetes Verzeichnis)'
    )
    parser.add_argument(
        '--name', '-n',
        type=str,
        help='Name des Projektordners (Standard: Name des aktuellen Verzeichnisses)'
    )
    parser.add_argument(
        '--source', '-s',
        type=str,
        help='Quellverzeichnis (Standard: aktuelles Verzeichnis)'
    )
    parser.add_argument(
        '--copy',
        type=str,
        help='Kopiert eine ZIP-Datei und erstellt neue ZIP mit anderem Projektnamen'
    )
    parser.add_argument(
        '--to',
        type=str,
        help='Zielverzeichnis für --copy'
    )
    parser.add_argument(
        '--rename',
        type=str,
        help='Neuer Projektordner-Name für --copy'
    )
    
    args = parser.parse_args()
    
    # Kopier-Modus
    if args.copy:
        if not args.to or not args.rename:
            print("Fehler: --copy erfordert --to und --rename")
            return 1
        
        copy_and_pack(args.copy, args.to, args.rename)
        return 0
    
    # Normaler Modus: ZIP erstellen
    create_mod_zip(
        source_dir=args.source,
        output_dir=args.output,
        project_name=args.name
    )
    return 0


if __name__ == '__main__':
    exit(main())

