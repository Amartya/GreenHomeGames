
/*
 * Reset to default values for the start of a new game
 */
function resetValues() {
   localStorage.valueR = 0.4;   // insulation rating
   localStorage.valueB = 0.8;   // furnace power
   localStorage.valueE = 0.3;   // furnace efficiency 
   localStorage.valueC = 0.2;   // energy cost (dollars per kWh)
   localStorage.thermostat = "round";  // thermostat type
}


/*
 * Start a new game
 */
function startNewGame() {
   resetValues();
   initValues();
}


function hideSettings() {
   var el = document.getElementById("settings-page");
   el.style.visibility = 'hidden';
}


function showSettings() {
   var el = document.getElementById("settings-page");
   el.style.visibility = 'visible';
}


/*
 * Initialize values in the settings dialog
 */
function initValues() {
   
   if (!localStorage.valueK) resetValues();
   
   with (settings) {
      outR.value = rangeR.value = localStorage.valueR;
      outB.value = rangeB.value = localStorage.valueB;
      outE.value = rangeE.value = localStorage.valueE;
      rangeC.value = localStorage.valueC;
      outC.value = '$' + rangeC.value;
      
      tstat = localStorage.thermostat;
      radioRound.setAttribute("checked", tstat == "round"); 
      radioProg.setAttribute("checked", tstat == "programmable");
      radioInet.setAttribute("checked", tstat == "internet");
   }
}


/*
 * Save new values in local storage
 */
function saveValues() {
   with (settings) {
      localStorage.valueR = outR.value = rangeR.valueAsNumber;
      localStorage.valueB = outB.value = rangeB.valueAsNumber;
      localStorage.valueE = outE.value = rangeE.valueAsNumber;
      localStorage.valueC = rangeC.valueAsNumber;
      outC.value = '$' + rangeC.valueAsNumber;
   }
}


/*
 * Change thermostat type
 */
function setThermostat(tstat) {
   localStorage.thermostat = tstat;
   with (settings) {
      radioRound.setAttribute("checked", tstat == "round"); 
      radioProg.setAttribute("checked", tstat == "programmable");
      radioInet.setAttribute("checked", tstat == "internet");
   }
   return false;
}


function adopt() {
   var el = document.getElementById("polar-bear");
   if (el) {
      el.style.visibility = 'visible';
   }
   return false;
}


