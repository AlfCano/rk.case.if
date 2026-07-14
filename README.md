# rk.case.if: Conditional Recoding & Date Fixing for RKWard

![Version](https://img.shields.io/badge/Version-0.0.1-blue.svg)
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
![RKWard](https://img.shields.io/badge/Platform-RKWard-green)
[![R Linter](https://github.com/AlfCano/rk.case.if/actions/workflows/lintr.yml/badge.svg)](https://github.com/AlfCano/rk.case.if/actions/workflows/lintr.yml)
![AI Gemini](https://img.shields.io/badge/AI-Gemini-4285F4?logo=googlegemini&logoColor=white)

**rk.case.if** is an advanced RKWard GUI plugin suite designed to handle the most common and frustrating data wrangling tasks: conditional recoding and repairing broken dates. 

Serving as the perfect companion to data cleaning workflows, this package provides a seamless graphical interface for the powerful `dplyr::if_else()`, `dplyr::case_when()`, `janitor`, and `lubridate` functions.

---

## 🌟 Key Features & Included Tools

This package installs a new toolset under the RKWard menu: **Data > Data Cleaning (janitor) > Conditional Recoding**.

### 1. Basic If/Else Recoder (Zero Code)
Designed for quick, binary recoding tasks without touching R syntax.
*   **Intuitive Dropdowns:** Select conditions like *Is exactly equal to*, *Contains text (`grepl`)*, *Is Empty (`is.na`)*, or *Is Numeric*.
*   **Automatic Formatting:** Automatically quotes your strings and handles the `dplyr::if_else()` logic under the hood to assign TRUE/FALSE outcomes.

### 2. Advanced Case_When Builder
The "Swiss Army Knife" for complex, multi-conditional data transformation.
*   **Matrix Interface:** Provides a spreadsheet-like grid to write multiple raw R conditions (e.g., `age > 18 & sex == 'M'`) and assign specific values in bulk.
*   **Safe Fallbacks:** Includes a dedicated input for the fallback value (`TRUE ~ fallback`), ensuring no data is left unassigned.

### 3. Fix Mixed Dates (Excel/Text Lifesaver)
A highly specialized tool that solves the infamous "Mixed Excel Dates" problem with a single click.
*   **Smart Detection:** When importing data from Excel or Google Forms, dates often break into a mix of serial numbers (e.g., `41653`) and strings (e.g., `15/05/2014`).
*   **Hybrid Engine:** This tool uses Regex (`grepl`) to detect numbers and applies `janitor::excel_numeric_to_date()`, while simultaneously passing the remaining strings through `lubridate` (ymd, dmy, etc.), merging them back into a single, clean `Date` column.

---

## 🌍 Internationalization (i18n)

The graphical interface automatically adapts to your RKWard language settings. Currently supported languages:
*   🇺🇸 English (Default)
*   🇪🇸 Spanish (`es`)
*   🇫🇷 French (`fr`)
*   🇩🇪 German (`de`)
*   🇧🇷 Portuguese (Brazil) (`pt_BR`)

---

## 🚀 Installation

You can install this plugin directly from GitHub or the R-Universe:

```R
# Install using remotes/devtools:
local({
  require(remotes)
  install_github("AlfCano/rk.case.if", force = TRUE)
})
```
*Restart RKWard after installation to load the new menu entries.*

---

## 🧪 Usage & Testing Workflow

To see the magic of the **Fix Mixed Dates** tool, paste this mock dataset into your RKWard console. It mimics a broken Excel import:

```R
messy_data <- data.frame(
  id = 1:4,
  messy_date = c("41653", "15/05/2014", "44197", "27/04/2013"),
  stringsAsFactors = FALSE
)
```

**Step-by-step Fix:**
1. Navigate to **Data -> Data Cleaning (janitor) -> Conditional Recoding -> Fix Mixed Dates**.
2. **Data Frame:** Select `messy_data`.
3. **Messy Date Variable:** Select `messy_date`.
4. **Text Date Format:** Select `Day-Month-Year (dmy)` *(since our text dates have days first)*.
5. Click **Submit**. 

**Result:** A clean dataframe will be printed to your output window, successfully converting both the `41653` Excel serials and the text strings into a unified, standard R Date format (`2014-01-14`, `2014-05-15`, etc.).

---

## 🛠️ Dependencies

This plugin generates code relying on the following highly optimized R packages:
*   `dplyr` (Data manipulation and conditional logic)
*   `janitor` (Excel numeric date parsing)
*   `lubridate` (String date parsing)
*   `stringr` (Text evaluation)

---

## 📝 Author & License

*   **Author:** Alfonso Cano ([@AlfCano](https://github.com/AlfCano))  
*   **Email:** alfonso.cano@correo.buap.mx  
*   **Assisted by:** Gemini, a large language model from Google.
*   **License:** GPL (>= 3)

This project is licensed under the **GPL (>= 3)** License.
