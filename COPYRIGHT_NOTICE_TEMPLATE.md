# COPYRIGHT NOTICE TEMPLATES FOR HEARIFY

**Document Date:** January 28, 2026
**Purpose:** Standardized copyright notices for all Hearify source files

---

## WHY COPYRIGHT NOTICES MATTER

- **Legal Protection:** Establishes ownership and rights
- **Date Evidence:** Proves when work was created
- **Professional Image:** Shows serious software development
- **License Clarity:** Makes terms clear to contributors/users
- **International Recognition:** Recognized worldwide under Berne Convention

---

## TEMPLATE 1: STANDARD SOURCE CODE HEADER (Recommended)

**Use for:** All .swift, .py, .js, .java, .md files

```swift
//
//  [FileName].swift
//  Hearify
//
//  Copyright © 2025-2026 Hearify, Inc.. All rights reserved.
//
//  This software and associated documentation files (the "Software") are the
//  proprietary and confidential information of [Your Name/Company].
//
//  NOTICE: All information contained herein is, and remains the property of
//  [Your Name/Company] and its suppliers, if any. The intellectual and
//  technical concepts contained herein are proprietary to [Your Name/Company]
//  and its suppliers and may be covered by U.S. and Foreign Patents, patents
//  in process, and are protected by trade secret or copyright law.
//
//  Dissemination of this information or reproduction of this material is
//  strictly forbidden unless prior written permission is obtained from
//  [Your Name/Company].
//
//  Unauthorized copying of this file, via any medium, is strictly prohibited.
//
//  Created by [Your Name] on [Date].
//  Last modified: [Date]
//
```

---

## TEMPLATE 2: CONCISE SOURCE CODE HEADER (Minimal)

**Use for:** Less sensitive files, utility scripts

```swift
//
//  [FileName].swift
//  Hearify
//
//  Copyright © 2025-2026 Hearify, Inc..
//  All rights reserved.
//
//  This file is part of Hearify, a proprietary auditory rehabilitation application.
//  Unauthorized use, copying, modification, or distribution is prohibited.
//
//  Created by [Your Name] on [Date].
//
```

---

## TEMPLATE 3: JSON/DATA FILE HEADER

**Use for:** .json, .csv, .txt data files

```json
{
  "_copyright": "Copyright © 2025-2026 Hearify, Inc.. All rights reserved.",
  "_license": "Proprietary and Confidential",
  "_notice": "This data file is part of Hearify. Unauthorized use is prohibited.",
  "_created": "[Date]",

  "data": [
    ...
  ]
}
```

---

## TEMPLATE 4: MARKDOWN/DOCUMENTATION HEADER

**Use for:** README.md, documentation files

```markdown
# [Document Title]

**Copyright © 2025-2026 Hearify, Inc.. All rights reserved.**

This document is proprietary and confidential. It is part of the Hearify™
auditory rehabilitation system and is protected by copyright and trade secret laws.

**NOTICE:** Unauthorized reproduction, distribution, or transmission of this
document, in whole or in part, is strictly prohibited.

**Trademarks:** Hearify™, HearifyV1™, and HearifyPro™ are trademarks of
[Your Name/Company].

---

[Document content starts here]
```

---

## TEMPLATE 5: STORYBOARD/XIB COMMENTS

**Use for:** Xcode Interface Builder files

```xml
<!--
  [FileName].storyboard
  Hearify

  Copyright © 2025-2026 Hearify, Inc.. All rights reserved.

  This interface design is proprietary and confidential.
  Unauthorized copying or reproduction is strictly prohibited.

  Created by [Your Name] on [Date].
-->
```

---

## TEMPLATE 6: SHELL SCRIPT HEADER

**Use for:** .sh, .bash scripts

```bash
#!/bin/bash
#
# [ScriptName].sh
# Hearify
#
# Copyright © 2025-2026 Hearify, Inc.. All rights reserved.
#
# This script is proprietary and confidential.
# Unauthorized use, copying, or distribution is prohibited.
#
# Created by [Your Name] on [Date].
#

# Script content starts here
```

---

## TEMPLATE 7: PYTHON SCRIPT HEADER

**Use for:** .py files

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
[FileName].py
Hearify

Copyright © 2025-2026 Hearify, Inc.. All rights reserved.

This file is part of Hearify, a proprietary auditory rehabilitation application.
Unauthorized use, copying, modification, or distribution is prohibited.

Created by [Your Name] on [Date].
Last modified: [Date]

Module Description:
    [Brief description of what this module does]
"""
```

---

## TEMPLATE 8: HTML/CSS HEADER

**Use for:** Web components (if applicable)

```html
<!--
  [FileName].html
  Hearify

  Copyright © 2025-2026 Hearify, Inc.. All rights reserved.

  This file is proprietary and confidential.
  Unauthorized reproduction is strictly prohibited.

  Created by [Your Name] on [Date].
-->
```

```css
/*
 * [FileName].css
 * Hearify
 *
 * Copyright © 2025-2026 Hearify, Inc.. All rights reserved.
 *
 * This stylesheet is proprietary and confidential.
 * Unauthorized use is prohibited.
 *
 * Created by [Your Name] on [Date].
 */
```

---

## TEMPLATE 9: APP BUNDLE/INFO.PLIST NOTICE

**Use for:** Info.plist, metadata files

```xml
<key>NSHumanReadableCopyright</key>
<string>Copyright © 2025-2026 Hearify, Inc.. All rights reserved. Hearify™ is a trademark of [Your Name/Company].</string>

<key>CFBundleGetInfoString</key>
<string>Hearify v1.0, Copyright © 2025-2026 Hearify, Inc., All rights reserved.</string>
```

---

## TEMPLATE 10: APP FOOTER/ABOUT SCREEN

**Use for:** In-app about screens

```swift
Text("Hearify™ v\(appVersion)")
    .font(.headline)

Text("Copyright © 2025-2026 Hearify, Inc.")
    .font(.subheadline)
    .foregroundColor(.secondary)

Text("All rights reserved.")
    .font(.caption)
    .foregroundColor(.secondary)

Text("Hearify™, HearifyV1™, and HearifyPro™ are trademarks of [Your Name/Company].")
    .font(.caption2)
    .foregroundColor(.secondary)
    .multilineTextAlignment(.center)

Text("Patent Pending")
    .font(.caption2)
    .foregroundColor(.secondary)
```

---

## HOW TO APPLY THESE NOTICES

### Automated Approach (Recommended)

**Step 1:** Create a script to add headers to all files:

```bash
#!/bin/bash
# add_copyright_headers.sh

# Define your copyright notice
COPYRIGHT_NOTICE="//
//  Copyright © 2025-2026 Hearify, Inc.. All rights reserved.
//  This file is part of Hearify. Unauthorized use is prohibited.
//

"

# Find all Swift files and add header
find . -name "*.swift" -type f | while read file; do
    # Check if file already has copyright
    if ! grep -q "Copyright" "$file"; then
        # Add copyright at the beginning
        echo "$COPYRIGHT_NOTICE" | cat - "$file" > temp && mv temp "$file"
        echo "Added copyright to: $file"
    fi
done
```

**Step 2:** Run the script:
```bash
chmod +x add_copyright_headers.sh
./add_copyright_headers.sh
```

### Manual Approach

1. Open each source file in Xcode
2. Copy the appropriate template from above
3. Paste at the top of the file
4. Fill in [placeholders] with actual values
5. Save the file

### Xcode File Template (Automatic for new files)

**Location:** `~/Library/Developer/Xcode/Templates/File Templates/`

Create a custom template with copyright notice:

```swift
//___FILEHEADER___
//
//  Copyright © 2025-2026 Hearify, Inc.. All rights reserved.
//  This file is part of Hearify. Unauthorized use is prohibited.
//

import Foundation

```

---

## FILL IN THE BLANKS

**Before using these templates, replace:**

- `Hearify, Inc.` → Your actual name or business entity
  - Example: "Hearify, Inc." or "Hearify Technologies LLC"

- `[Your Name]` → Your full name as creator
  - Example: "Hearify, Inc."

- `[Date]` → Creation date in format: "January 28, 2026"

- `[FileName]` → Actual filename
  - Example: "FirebaseManager.swift"

- `[Your Name/Company]` → Consistent reference throughout
  - Example: Use same format everywhere for consistency

---

## EXAMPLE FILLED-IN HEADER

**Before:**
```swift
//
//  [FileName].swift
//  Hearify
//
//  Copyright © 2025-2026 Hearify, Inc.. All rights reserved.
//
```

**After:**
```swift
//
//  FirebaseManager.swift
//  Hearify
//
//  Copyright © 2025-2026 Hearify, Inc.. All rights reserved.
//  This file is part of Hearify, a proprietary auditory rehabilitation application.
//  Unauthorized use, copying, modification, or distribution is prohibited.
//
//  Created by Hearify, Inc. on October 1, 2025.
//  Last modified: January 28, 2026
//
```

---

## EXISTING FILES THAT NEED HEADERS

Based on codebase analysis, add copyright headers to:

### Core App Files
- ✅ `HearifyV1App.swift`
- ✅ `ContentView.swift`
- ✅ All files in `/Managers/` directory
- ✅ All files in `/Models/` directory
- ✅ All files in `/Views/` directory

### Data Files
- ✅ CSV data files (word lists, phonemes)
- ✅ JSON configuration files
- ✅ Audio resource metadata

### Documentation
- ✅ README.md
- ✅ CLAUDE.md
- ✅ Any technical documentation

### Configuration
- ✅ Info.plist
- ✅ GoogleService-Info.plist metadata (comment at top)

---

## INTERNATIONAL COPYRIGHT SYMBOL

**Text versions:**
- ASCII: `Copyright (c) 2025-2026`
- Unicode: `Copyright © 2025-2026` (preferred)
- Symbol: `©` (use Unicode character U+00A9)

**In Swift:**
```swift
let copyrightNotice = "Copyright © 2025-2026 Your Name. All rights reserved."
// Or
let copyrightNotice = "Copyright \u{00A9} 2025-2026 Your Name. All rights reserved."
```

---

## LICENSE VARIATIONS

### If Open Sourcing (Future)

**MIT License Header:**
```swift
//
//  [FileName].swift
//  Hearify
//
//  Copyright © 2025-2026 [Your Name].
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  [Full MIT License text]
//
```

**Apache 2.0 Header:**
```swift
//
//  Copyright © 2025-2026 [Your Name]
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
```

**Note:** Only use open source licenses if you intend to make code public. For proprietary apps, use Template 1 or 2.

---

## TRADEMARK NOTICES

**In addition to copyright, include trademark notices:**

### In-App Locations:
1. **Splash screen:** "Hearify™"
2. **About screen:** Full trademark notice
3. **Settings screen:** Copyright notice
4. **App Store description:** "Hearify™ is a trademark of [Your Name/Company]"

### In Documentation:
```markdown
Hearify™, HearifyV1™, and HearifyPro™ are trademarks of [Your Name/Company].
All other trademarks are property of their respective owners.
```

---

## CHECKLIST FOR APPLYING COPYRIGHT NOTICES

### Immediate Actions:
- [ ] Decide on name format (personal or company)
- [ ] Fill in all [placeholders] in templates
- [ ] Add notice to HearifyV1App.swift
- [ ] Add notice to FirebaseManager.swift
- [ ] Add notice to all Manager files
- [ ] Add notice to all Model files
- [ ] Add notice to all View files

### Within 1 Week:
- [ ] Add notices to all remaining Swift files
- [ ] Add notices to data files (CSV, JSON)
- [ ] Update Info.plist with copyright
- [ ] Add copyright to README.md
- [ ] Create about screen with copyright notice

### Within 1 Month:
- [ ] Set up Xcode file template with auto-copyright
- [ ] Document copyright practices for team
- [ ] Add trademark notices to app
- [ ] Register copyright with US Copyright Office

---

## GIT COMMIT MESSAGE

When adding copyright notices, use a clear commit message:

```bash
git add .
git commit -m "Add copyright notices to all source files

- Added copyright headers to all Swift files
- Added proprietary notices to protect IP
- Updated Info.plist with copyright metadata
- Added trademark notices to documentation

Copyright © 2025-2026 [Your Name]. All rights reserved."
```

---

## LEGAL DISCLAIMER

**Important Notes:**
1. Copyright exists automatically when you create original work
2. These notices provide additional legal benefits
3. © symbol is optional but recommended
4. Year should be year of first publication
5. Update year range as you maintain the code (2025-2026, 2025-2027, etc.)
6. Use consistent formatting throughout your project
7. Consult an attorney for specific legal advice

---

## ADDITIONAL RESOURCES

**Copyright Registration:**
- US Copyright Office: https://www.copyright.gov
- Electronic Copyright Office (eCO): https://eco.copyright.gov
- Cost: $65 for electronic registration

**Trademark Information:**
- USPTO Trademark Search: https://www.uspto.gov/trademarks
- TESS (Trademark Electronic Search System)

**Legal Templates:**
- LegalZoom: https://www.legalzoom.com
- Rocket Lawyer: https://www.rocketlawyer.com
- Nolo: https://www.nolo.com

---

**Document prepared by:** Claude Code Legal Compliance System
**For:** Hearify IP Protection
**Date:** January 28, 2026
**Version:** 1.0

**Instructions:** Review with legal counsel before applying to ensure compliance with your specific situation.
