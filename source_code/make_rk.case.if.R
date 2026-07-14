local({
  # =========================================================================================
  # 1. Package Definition and Metadata
  # =========================================================================================
  require(rkwarddev)
  rkwarddev.required("0.10-3")

  package_about <- rk.XML.about(
    name = "rk.case.if",
    author = person(
      given = "Alfonso",
      family = "Cano",
      email = "alfonso.cano@correo.buap.mx",
      role = c("aut", "cre")
    ),
    about = list(
      desc = "An RKWard plugin suite for conditional recoding, case_when logic, and fixing mixed dates using dplyr, janitor, and lubridate.",
      version = "0.0.1",
      url = "https://github.com/AlfCano/rk.case.if",
      license = "GPL (>= 3)"
    )
  )

  dependencies_node <- rk.XML.dependencies(
    dependencies = list(R.min = "3.5.0"),
    package = list(
      c(name = "dplyr"),
      c(name = "janitor"),
      c(name = "lubridate"),
      c(name = "stringr")
    )
  )

  common_hierarchy <- list("data", "Data Cleaning (janitor)", "Case When")

  js_helpers <- "
    function getCol(id) {
        var raw = getValue(id);
        if (!raw) return 'NULL';
        var parts = raw.split(/[\\[\\]\\$]+/).filter(Boolean);
        if (parts.length > 0) {
            var last = parts[parts.length - 1];
            return last.replace(/[\"']/g, '');
        }
        return raw;
    }

    function getCleanArray(id) {
        var rawValue = getValue(id);
        if (!rawValue) return [];
        var raw = rawValue.split(/\\n/).filter(Boolean);
        return raw.map(function(item) {
            return item.replace(/[\\n\\r]/g, '');
        });
    }
  "

  # =========================================================================================
  # MAIN PLUGIN: Basic If/Else Recoder (Cero Código)
  # =========================================================================================

  vs_basic <- rk.XML.varselector(id.name = "vs_basic")
  bas_df <- rk.XML.varslot("Data Frame", source = "vs_basic", required = TRUE, classes = "data.frame", id.name = "bas_df")
  bas_var <- rk.XML.varslot("Target Variable", source = "vs_basic", required = TRUE, id.name = "bas_var")

  bas_cond <- rk.XML.dropdown("Condition (If Variable...)", id.name = "bas_cond", options = list(
    "Is exactly equal to (==)" = list(val = "==", chk = TRUE),
    "Is NOT equal to (!=)" = list(val = "!="),
    "Is Greater than (>)" = list(val = ">"),
    "Is Less than (<)" = list(val = "<"),
    "Contains text (grepl)" = list(val = "grepl"),
    "Is Empty / Missing (is.na)" = list(val = "is.na"),
    "Is Numeric (is.numeric)" = list(val = "is.numeric"),
    "Is Character/Text (is.character)" = list(val = "is.character")
  ))

  bas_val <- rk.XML.input("Value to check (Leave empty for is.na/is.numeric)", id.name = "bas_val")
  bas_text_chk <- rk.XML.cbox("Treat check value as text (adds quotes)", value = "1", chk = TRUE, id.name = "bas_text_chk")

  bas_true <- rk.XML.input("If TRUE, assign this value:", id.name = "bas_true")
  bas_false <- rk.XML.input("If FALSE, assign this value (Use target variable name to keep original):", id.name = "bas_false")
  bas_out_text <- rk.XML.cbox("Treat assigned values as text (adds quotes)", value = "1", chk = TRUE, id.name = "bas_out_text")

  bas_outname <- rk.XML.input("Output Variable Name (Use original name to overwrite)", initial = "new_var", required = TRUE, id.name = "bas_outname")

  bas_save <- rk.XML.saveobj("Save Result As", initial = "recoded_df", chk = TRUE, id.name = "bas_save")

  tab_bas_in <- rk.XML.col(bas_df, bas_var, rk.XML.frame(bas_cond, bas_val, bas_text_chk, label="Condition Rule"))
  tab_bas_out <- rk.XML.col(rk.XML.frame(bas_true, bas_false, bas_out_text, label="Outcomes"), bas_outname, rk.XML.stretch(), bas_save)

  dialog_basic <- rk.XML.dialog(label = "Basic If/Else Recoder", child = rk.XML.row(vs_basic, rk.XML.tabbook(tabs = list("Condition" = tab_bas_in, "Outcomes & Save" = tab_bas_out))))

  js_calc_basic <- rk.paste.JS(js_helpers, "
    var df = getValue('bas_df'); if(!df) return;
    var v = getCol('bas_var');
    var cond = getValue('bas_cond');
    var val = getValue('bas_val');
    var is_txt = getValue('bas_text_chk') === '1';

    var t_val = getValue('bas_true');
    var f_val = getValue('bas_false');
    var out_txt = getValue('bas_out_text') === '1';
    var out_name = getValue('bas_outname');

    var val_str = is_txt ? \"'\" + val + \"'\" : val;
    var t_str = out_txt ? \"'\" + t_val + \"'\" : t_val;
    var f_str = out_txt ? \"'\" + f_val + \"'\" : f_val;

    var c_code = '';
    if(cond === 'is.na') c_code = 'is.na(' + v + ')';
    else if(cond === 'is.numeric') c_code = 'is.numeric(' + v + ')';
    else if(cond === 'is.character') c_code = 'is.character(' + v + ')';
    else if(cond === 'grepl') c_code = 'grepl(' + val_str + ', ' + v + ')';
    else c_code = v + ' ' + cond + ' ' + val_str;

    echo(\"recoded_df <- \" + df + \" %>%\\n\");
    echo(\"  dplyr::mutate(\\n\");
    echo(\"    `\" + out_name + \"` = dplyr::if_else(\" + c_code + \", \" + t_str + \", \" + f_str + \")\\n\");
    echo(\"  )\\n\");
  ")

  js_print_basic <- rk.paste.JS("
    var save = getValue('bas_save');
    echo(\"rk.header('Basic If/Else Recoder')\\n\");
    echo(\"rk.print('Data successfully saved to object: \" + save + \"')\\n\");
    echo(\"rk.results(head(recoded_df))\\n\");
  ")


  # =========================================================================================
  # COMPONENTE SECUNDARIO 1: Advanced Case_When Builder
  # =========================================================================================

  vs_adv <- rk.XML.varselector(id.name = "vs_adv")
  adv_df <- rk.XML.varslot("Data Frame", source = "vs_adv", required = TRUE, classes = "data.frame", id.name = "adv_df")

  adv_mat <- rk.XML.matrix(
    label = "Case_When Rules",
    mode = "string",
    min = 1,
    horiz_headers = c("Condition (e.g. age > 18)", "Assigned Value (e.g. 'Adult')"),
    id.name = "adv_mat"
  )

  adv_fallback <- rk.XML.input("Fallback Value (If no rules match, TRUE ~ ...)", initial = "NA_character_", id.name = "adv_fallback")
  adv_outname <- rk.XML.input("Output Variable Name", initial = "new_var", required = TRUE, id.name = "adv_outname")
  adv_save <- rk.XML.saveobj("Save Result As", initial = "casewhen_df", chk = TRUE, id.name = "adv_save")

  tab_adv_in <- rk.XML.col(adv_df, rk.XML.text("Write raw R syntax. Remember to quote string values (e.g., 'Category A')."), adv_mat, adv_fallback)
  tab_adv_out <- rk.XML.col(adv_outname, rk.XML.stretch(), adv_save)

  dialog_adv <- rk.XML.dialog(label = "Advanced Case_When Builder", child = rk.XML.row(vs_adv, rk.XML.tabbook(tabs = list("Rules" = tab_adv_in, "Output" = tab_adv_out))))

  js_calc_adv <- rk.paste.JS(js_helpers, "
    var df = getValue('adv_df'); if(!df) return;
    var conds = getCleanArray('adv_mat.0');
    var vals = getCleanArray('adv_mat.1');
    var fallback = getValue('adv_fallback');
    var out_name = getValue('adv_outname');

    echo(\"casewhen_df <- \" + df + \" %>%\\n\");
    echo(\"  dplyr::mutate(\\n\");
    echo(\"    `\" + out_name + \"` = dplyr::case_when(\\n\");

    for(var i=0; i < conds.length; i++) {
        var c = conds[i];
        var v = (vals[i] && vals[i] !== '') ? vals[i] : 'NA';
        echo(\"      \" + c + \" ~ \" + v + \",\\n\");
    }

    if(fallback === '') fallback = 'NA';
    echo(\"      TRUE ~ \" + fallback + \"\\n\");
    echo(\"    )\\n  )\\n\");
  ")

  js_print_adv <- rk.paste.JS("
    var save = getValue('adv_save');
    echo(\"rk.header('Advanced Case_When Builder')\\n\");
    echo(\"rk.print('Data successfully saved to object: \" + save + \"')\\n\");
    echo(\"rk.results(head(casewhen_df))\\n\");
  ")

  comp_adv <- rk.plugin.component("Advanced Case When", xml = list(dialog = dialog_adv), js = list(require = "dplyr", calculate = js_calc_adv, printout = js_print_adv), hierarchy = common_hierarchy)


  # =========================================================================================
  # COMPONENTE SECUNDARIO 2: Fix Mixed Dates (Excel/Text)
  # =========================================================================================

  vs_date <- rk.XML.varselector(id.name = "vs_date")
  date_df <- rk.XML.varslot("Data Frame", source = "vs_date", required = TRUE, classes = "data.frame", id.name = "date_df")
  date_var <- rk.XML.varslot("Messy Date Variable", source = "vs_date", required = TRUE, id.name = "date_var")

  date_fmt <- rk.XML.dropdown("Text Date Format (for non-Excel dates)", id.name = "date_fmt", options = list(
    "Year-Month-Day (ymd)" = list(val = "ymd", chk = TRUE),
    "Day-Month-Year (dmy)" = list(val = "dmy"),
    "Month-Day-Year (mdy)" = list(val = "mdy"),
    "Year-Month-Day Hour:Min:Sec (ymd_hms)" = list(val = "ymd_hms")
  ))

  date_outname <- rk.XML.input("Output Variable Name (Use original to overwrite)", initial = "date_clean", required = TRUE, id.name = "date_outname")
  date_save <- rk.XML.saveobj("Save Result As", initial = "fixed_dates_df", chk = TRUE, id.name = "date_save")

  dialog_date <- rk.XML.dialog(label = "Fix Mixed Dates (Excel/Text)", child = rk.XML.row(vs_date, rk.XML.col(
    date_df, date_var,
    rk.XML.text("Detects and converts Microsoft Excel serial numbers (e.g., 44197) and standard text dates simultaneously."),
    date_fmt, date_outname, rk.XML.stretch(), date_save
  )))

  js_calc_date <- rk.paste.JS(js_helpers, "
    var df = getValue('date_df'); if(!df) return;
    var v = getCol('date_var');
    var fmt = getValue('date_fmt');
    var out_name = getValue('date_outname');

    echo(\"fixed_dates_df <- \" + df + \" %>%\\n\");
    echo(\"  dplyr::mutate(\\n\");
    echo(\"    `\" + out_name + \"` = dplyr::case_when(\\n\");

    echo(\"      grepl('^[0-9]+$', as.character(`\" + v + \"`)) ~ as.character(suppressWarnings(janitor::excel_numeric_to_date(as.numeric(as.character(`\" + v + \"`))))),\\n\");
    echo(\"      TRUE ~ as.character(suppressWarnings(lubridate::\" + fmt + \"(as.character(`\" + v + \"`))))\\n\");
    echo(\"    ),\\n\");

    echo(\"    `\" + out_name + \"` = as.Date(`\" + out_name + \"`)\\n\");
    echo(\"  )\\n\");
  ")

  js_print_date <- rk.paste.JS("
    var save = getValue('date_save');
    echo(\"rk.header('Fix Mixed Dates (Excel/Text)')\\n\");
    echo(\"rk.print('Data successfully saved to object: \" + save + \"')\\n\");
    echo(\"rk.results(head(fixed_dates_df))\\n\");
  ")

  comp_date <- rk.plugin.component("Fix Mixed Dates", xml = list(dialog = dialog_date), js = list(require = c("dplyr", "janitor", "lubridate"), calculate = js_calc_date, printout = js_print_date), hierarchy = common_hierarchy)


  # =========================================================================================
  # 4. Final Skeleton Assembly
  # =========================================================================================
  rk.plugin.skeleton(
    about = package_about,
    path = ".",

    # EL MAIN PLUGIN VA DIRECTO A LA RAÍZ
    xml = list(dialog = dialog_basic),
    js = list(require = "dplyr", calculate = js_calc_basic, printout = js_print_basic),

    # LOS COMPONENTES SECUNDARIOS VAN A LA LISTA
    components = list(comp_adv, comp_date),

    # EL NOMBRE DEL MAPA ES EL DEL MAIN PLUGIN
    pluginmap = list(name = "Basic Recoder", hierarchy = common_hierarchy),

    dependencies = dependencies_node,
    create = c("pmap", "xml", "js", "desc", "rkh"),
    overwrite = TRUE,
    load = TRUE
  )
})
