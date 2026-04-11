#!/usr/bin/env python3
"""
Fix invalid_constant errors in Flutter Dart files.
Strategy: Remove 'const' keyword from any const constructor that directly or
indirectly (within the same expression block) references non-const AppTheme properties.
"""

import re
import sys

# Non-const AppTheme properties
NON_CONST_PROPS = [
    'AppTheme.background',
    'AppTheme.cardBackground',
    'AppTheme.textPrimary',
    'AppTheme.textSecondary',
    'AppTheme.divider',
    'AppTheme.navBackground',
    'AppTheme.primaryLight',
    'AppTheme.successLight',
    'AppTheme.warningLight',
    'AppTheme.criticalLight',
    'AppTheme.errorCardBg',
    'AppTheme.warningCardBg',
    'AppTheme.errorCardBorder',
    'AppTheme.warningCardBorder',
]

FILES = [
    'lib/screens/home_screen.dart',
    'lib/screens/profile_screen.dart',
    'lib/screens/pharmacies_screen.dart',
    'lib/screens/ilac_ekle_screen.dart',
    'lib/screens/qr_scanner_screen.dart',
]

def has_non_const_ref(text):
    """Check if text contains any non-const AppTheme reference."""
    for prop in NON_CONST_PROPS:
        if prop in text:
            return True
    return False

def find_matching_close(lines, start_line, start_col):
    """
    Find the matching closing paren/bracket for an opening one.
    Returns (line_idx, col_idx) of the closing paren.
    """
    # Find what the opening char is
    line = lines[start_line]
    # Find the opening paren after start_col
    open_pos = line.find('(', start_col)
    if open_pos == -1:
        return None

    depth = 0
    for li in range(start_line, min(start_line + 50, len(lines))):
        l = lines[li]
        start = open_pos if li == start_line else 0
        for ci in range(start, len(l)):
            c = l[ci]
            if c == '(':
                depth += 1
            elif c == ')':
                depth -= 1
                if depth == 0:
                    return (li, ci)
    return None

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    lines = content.split('\n')
    original_lines = lines[:]

    changed = True
    iteration = 0
    while changed and iteration < 20:
        changed = False
        iteration += 1

        i = 0
        while i < len(lines):
            line = lines[i]

            # Find all 'const ' occurrences in this line
            const_positions = []
            pos = 0
            while True:
                idx = line.find('const ', pos)
                if idx == -1:
                    break
                # Make sure it's a standalone 'const' keyword (not part of a word)
                if idx > 0 and (line[idx-1].isalnum() or line[idx-1] == '_'):
                    pos = idx + 1
                    continue
                const_positions.append(idx)
                pos = idx + 1

            for const_idx in reversed(const_positions):
                # Check if this 'const' is part of a constructor call
                after_const = line[const_idx + 6:]  # after 'const '

                # Get the block from const onwards (multi-line)
                # Find the opening paren to determine the extent of this const expression
                paren_pos = line.find('(', const_idx + 6)
                if paren_pos == -1:
                    # Maybe it's a const on its own line before a constructor on next line
                    # Or const [...] list
                    # Check if there's a '[' instead
                    bracket_pos = line.find('[', const_idx + 6)
                    if bracket_pos != -1:
                        # collect block text
                        block_text = line[const_idx:]
                        for j in range(i+1, min(i+15, len(lines))):
                            block_text += '\n' + lines[j]
                            if ']' in lines[j]:
                                break
                        if has_non_const_ref(block_text):
                            lines[i] = line[:const_idx] + line[const_idx+6:]
                            changed = True
                            break
                    continue

                # Find matching close paren
                result = find_matching_close(lines, i, const_idx + 6)
                if result is None:
                    # Fallback: just grab next 15 lines
                    block_text = '\n'.join(lines[i:min(i+15, len(lines))])
                else:
                    end_li, end_ci = result
                    block_lines = lines[i:end_li+1]
                    block_text = '\n'.join(block_lines)

                if has_non_const_ref(block_text):
                    lines[i] = line[:const_idx] + line[const_idx+6:]
                    changed = True
                    break  # restart this line's const positions since line changed

            i += 1

    new_content = '\n'.join(lines)
    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Fixed: {filepath}")
        return True
    else:
        print(f"No changes: {filepath}")
        return False

if __name__ == '__main__':
    import os

    # Run from the project root
    project_root = '/Users/canyasa/Desktop/teknofest projesi/Asenkron-Akilli-Ilac-Takibi-Sistemi/can_app'
    os.chdir(project_root)

    for filepath in FILES:
        process_file(filepath)

    print("\nDone! Now run: flutter analyze 2>&1 | grep -c error")
