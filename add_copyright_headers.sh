#!/bin/bash
#
# add_copyright_headers.sh
# Automatically adds copyright headers to all Swift files in Hearify project
#
# Copyright © 2025-2026 Veer Chopra. All rights reserved.
# This script is part of the Hearify IP protection process.
#
# Usage: ./add_copyright_headers.sh
# Warning: This will modify files. Commit your work to git first!
#

# ANSI color codes for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration - CUSTOMIZE THESE VALUES
COPYRIGHT_OWNER="Hearify, Inc."
COPYRIGHT_YEARS="2025-2026"
PROJECT_NAME="Hearify"
CREATION_DATE=$(date +"%B %d, %Y")

# Counter variables
FILES_PROCESSED=0
FILES_SKIPPED=0
FILES_MODIFIED=0

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}    HEARIFY COPYRIGHT HEADER AUTOMATION SCRIPT${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}⚠️  WARNING: This script will modify Swift files!${NC}"
echo -e "${YELLOW}    Make sure you have committed your work to git first.${NC}"
echo ""
echo -e "Copyright Owner: ${GREEN}${COPYRIGHT_OWNER}${NC}"
echo -e "Copyright Years: ${GREEN}${COPYRIGHT_YEARS}${NC}"
echo -e "Project Name: ${GREEN}${PROJECT_NAME}${NC}"
echo ""

# Ask for confirmation
read -p "Do you want to proceed? (yes/no): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy][Ee][Ss]$ ]]; then
    echo -e "${RED}❌ Operation cancelled by user.${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}🔍 Searching for Swift files...${NC}"
echo ""

# Create backup directory
BACKUP_DIR="./copyright_backups_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
echo -e "${GREEN}📁 Created backup directory: ${BACKUP_DIR}${NC}"
echo ""

# Function to create copyright header
create_copyright_header() {
    local filename="$1"
    local basename=$(basename "$filename")

    cat <<EOF
//
//  ${basename}
//  ${PROJECT_NAME}
//
//  Copyright © ${COPYRIGHT_YEARS} ${COPYRIGHT_OWNER}. All rights reserved.
//
//  This file is part of ${PROJECT_NAME}, a proprietary auditory rehabilitation application.
//  Unauthorized use, copying, modification, or distribution is strictly prohibited.
//
//  NOTICE: All information contained herein is, and remains the property of
//  ${COPYRIGHT_OWNER}. The intellectual and technical concepts contained herein
//  are proprietary and may be covered by U.S. and Foreign Patents, patents in
//  process, and are protected by trade secret or copyright law.
//
//  Dissemination of this information or reproduction of this material is
//  strictly forbidden unless prior written permission is obtained.
//
//  Created on ${CREATION_DATE}.
//

EOF
}

# Function to check if file already has copyright
has_copyright() {
    local file="$1"
    if grep -q "Copyright ©" "$file"; then
        return 0  # Has copyright
    else
        return 1  # No copyright
    fi
}

# Function to process a single Swift file
process_swift_file() {
    local filepath="$1"
    local filename=$(basename "$filepath")
    local dirname=$(dirname "$filepath")

    FILES_PROCESSED=$((FILES_PROCESSED + 1))

    # Skip if file already has copyright
    if has_copyright "$filepath"; then
        echo -e "${YELLOW}⏭️  SKIP:${NC} ${filepath}"
        echo -e "    └─ Already has copyright notice"
        FILES_SKIPPED=$((FILES_SKIPPED + 1))
        return
    fi

    # Create backup
    cp "$filepath" "${BACKUP_DIR}/${filename}.bak"

    # Create temp file with copyright header
    TEMP_FILE=$(mktemp)
    create_copyright_header "$filename" > "$TEMP_FILE"
    cat "$filepath" >> "$TEMP_FILE"

    # Replace original file
    mv "$TEMP_FILE" "$filepath"

    echo -e "${GREEN}✅ ADDED:${NC} ${filepath}"
    FILES_MODIFIED=$((FILES_MODIFIED + 1))
}

# Find all Swift files and process them
echo -e "${BLUE}📝 Processing Swift files...${NC}"
echo ""

# Process Swift files in main project directory
find "./HearifyV1" -name "*.swift" -type f 2>/dev/null | while read file; do
    # Skip certain directories if needed
    if [[ "$file" == *"/Pods/"* ]] || [[ "$file" == *"/DerivedData/"* ]]; then
        continue
    fi
    process_swift_file "$file"
done

# Also check for any Swift files in the root
find . -maxdepth 1 -name "*.swift" -type f 2>/dev/null | while read file; do
    process_swift_file "$file"
done

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}                    SUMMARY REPORT${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "📊 Files processed:     ${GREEN}${FILES_PROCESSED}${NC}"
echo -e "✅ Files modified:      ${GREEN}${FILES_MODIFIED}${NC}"
echo -e "⏭️  Files skipped:       ${YELLOW}${FILES_SKIPPED}${NC}"
echo -e "📁 Backups saved to:    ${BACKUP_DIR}"
echo ""

if [ $FILES_MODIFIED -gt 0 ]; then
    echo -e "${GREEN}✨ Copyright headers successfully added to ${FILES_MODIFIED} files!${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  IMPORTANT NEXT STEPS:${NC}"
    echo -e "1. Review the changes: ${BLUE}git diff${NC}"
    echo -e "2. Test your app to ensure nothing broke"
    echo -e "3. Commit the changes: ${BLUE}git add . && git commit -m 'Add copyright headers'${NC}"
    echo -e "4. If anything went wrong, restore from: ${BACKUP_DIR}"
    echo ""
else
    echo -e "${YELLOW}ℹ️  No files were modified. All files already have copyright notices.${NC}"
    echo ""
fi

# Offer to show git diff
echo -e "${BLUE}Would you like to see the changes (git diff)? (yes/no):${NC}"
read SHOW_DIFF
if [[ "$SHOW_DIFF" =~ ^[Yy][Ee][Ss]$ ]]; then
    git diff
fi

echo ""
echo -e "${GREEN}✅ Script completed successfully!${NC}"
echo ""
