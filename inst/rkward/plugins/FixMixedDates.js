// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(dplyr)\n");	echo("require(janitor)\n");	echo("require(lubridate)\n");
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated
	
    function getCol(id) {
        var raw = getValue(id);
        if (!raw) return 'NULL';
        var parts = raw.split(/[\[\]\$]+/).filter(Boolean);
        if (parts.length > 0) {
            var last = parts[parts.length - 1];
            return last.replace(/["']/g, '');
        }
        return raw;
    }

    function getCleanArray(id) {
        var rawValue = getValue(id);
        if (!rawValue) return [];
        var raw = rawValue.split(/\n/).filter(Boolean);
        return raw.map(function(item) {
            return item.replace(/[\n\r]/g, '');
        });
    }
  
	
    var df = getValue('date_df'); if(!df) return;
    var v = getCol('date_var');
    var fmt = getValue('date_fmt');
    var out_name = getValue('date_outname');

    echo("fixed_dates_df <- " + df + " %>%\n");
    echo("  dplyr::mutate(\n");
    echo("    `" + out_name + "` = dplyr::case_when(\n");

    echo("      grepl('^[0-9]+$', as.character(`" + v + "`)) ~ as.character(suppressWarnings(janitor::excel_numeric_to_date(as.numeric(as.character(`" + v + "`))))),\n");
    echo("      TRUE ~ as.character(suppressWarnings(lubridate::" + fmt + "(as.character(`" + v + "`))))\n");
    echo("    ),\n");

    echo("    `" + out_name + "` = as.Date(`" + out_name + "`)\n");
    echo("  )\n");
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Fix Mixed Dates results")).print();
	
    var save = getValue('date_save');
    echo("rk.header('Fix Mixed Dates (Excel/Text)')\n");
    echo("rk.print('Data successfully saved to object: " + save + "')\n");
    echo("rk.results(head(fixed_dates_df))\n");
  
	//// save result object
	// read in saveobject variables
	var dateSave = getValue("date_save");
	var dateSaveActive = getValue("date_save.active");
	var dateSaveParent = getValue("date_save.parent");
	// assign object to chosen environment
	if(dateSaveActive) {
		echo(".GlobalEnv$" + dateSave + " <- fixed_dates_df\n");
	}

}

