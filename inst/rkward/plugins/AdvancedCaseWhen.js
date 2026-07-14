// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(dplyr)\n");
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
  
	
    var df = getValue('adv_df'); if(!df) return;
    var conds = getCleanArray('adv_mat.0');
    var vals = getCleanArray('adv_mat.1');
    var fallback = getValue('adv_fallback');
    var out_name = getValue('adv_outname');

    echo("casewhen_df <- " + df + " %>%\n");
    echo("  dplyr::mutate(\n");
    echo("    `" + out_name + "` = dplyr::case_when(\n");

    for(var i=0; i < conds.length; i++) {
        var c = conds[i];
        var v = (vals[i] && vals[i] !== '') ? vals[i] : 'NA';
        echo("      " + c + " ~ " + v + ",\n");
    }

    if(fallback === '') fallback = 'NA';
    echo("      TRUE ~ " + fallback + "\n");
    echo("    )\n  )\n");
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Advanced Case When results")).print();
	
    var save = getValue('adv_save');
    echo("rk.header('Advanced Case_When Builder')\n");
    echo("rk.print('Data successfully saved to object: " + save + "')\n");
    echo("rk.results(head(casewhen_df))\n");
  
	//// save result object
	// read in saveobject variables
	var advSave = getValue("adv_save");
	var advSaveActive = getValue("adv_save.active");
	var advSaveParent = getValue("adv_save.parent");
	// assign object to chosen environment
	if(advSaveActive) {
		echo(".GlobalEnv$" + advSave + " <- casewhen_df\n");
	}

}

