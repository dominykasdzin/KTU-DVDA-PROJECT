# Užduoties rezultatai

Visų pirma, prieš atliekant užduotį, buvo sujungti užduoties aprašyme pateikti duomenys į vieną mokymo masyvą, ši procedūra pateikiama `3-R` kataloge, faile `data_transformation.R`.

Sujungus duomenis ir išsaugojus juos kataloge `1-data` kaip `train_data.csv`, buvo atlikta šio naujai sugeneruoto failo analizė - apžvelgti kintamieji, apskaičiuoti jų įvairūs statistiniai rodikliai. Visa ši procedūra yra atliekama kataloge `2-report`. Ten pateikiamas ir pats R Markdown failas `report.Rmd`, ir jo sugeneruota HTML analizė `report.html`.

Išnagrinėjus duomenis pereita prie jų modeliavimo, visa procedūra yra pateikiama katalogo `3-R` faile `modelling.R`: čia importuoti duomenys visų pirma buvo išskirstysti į tris imtis: mokymosi, validacijos ir testavimo. Išskaidžius duomenis pereita prie pačio modelio parinkimo - visų pirma buvo taikomas automatinis modelio parinkimas, naudojant `h2o.automl` komandą. Šiuo būdu rastas modelis pasiekė minimalų reikalingą 0.8 AUC, tačiau ieškant geresnio AUC įverčio buvo pereita ir prie modelio paieškos rankiniu būdu. 

Išbandant įvairius modelius ir įvairius jų parametrus kaip tiksliausias pagal AUC buvo identifikuotas Gradient Boosting Machine (GBM) modelis, galutinei testavimo imčiai siekęs beveik 0.85 AUC. Tokį rezultatą pavyko pasiekti su parametrais `ntrees = 46` ir `max_depth = 17`. Kataloge `4-model` šis modelis yra išsaugotas kaip `gbm_model1`, o jo pateikti spėjimai užduoties `test_data.csv` failui yra pateikiami `5-predictions` kataloge, faile `predictions3.csv`.

Atlikus reikiamų duomenų prognozavimą pagal šį modelį buvo sukurta interaktyvi `R Shiny` aplikacija, pateikiama kataloge `app`. Šioje aplikacijoje galima įvesti besikreipiančio į banką kliento duomenis ir jau aptarto GBM modelio pagalba nustatyti, ar paskolos prašymą galima patenkinti, ar jį reikia atmesti kaip per daug rizikingą. Taip pat programoje galima matyti pagrindinę informaciją apie modelį ir didžiausią įtaką sprendimui turinčius kintamuosius.

# Kodo paleidimas

Norint pakartoti atliktus veiksmus ar tęsti darbą su turimais modeliais reikia nusiklonuoti pakanka parsisiųsti užduoties aprašyme pateiktus duomenis ir šios GitHub repozitorijos failus, tuomet įkelti atsisiųstus duomenis į `1-data` katalogą. Daugiau kode keisti nieko nereikia, visi užkraunami failai yra apibūdinami dinamiškai ir veiks be papildomo kodo koregavimo.
