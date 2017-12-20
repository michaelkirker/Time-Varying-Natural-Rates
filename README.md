# Time-Varying-Natural-Rates

This repository contains the model code, estimation code, and example data for the model used in the paper "Does natural rate variation matter? Evidence from New Zealand", Reserve Bank of New Zealand Discussion Paper DP2008/17.

This code is designed to run in Matlab 2016b using version 7.20090626 of the [IRIS toolbox](https://iristoolbox.codeplex.com/ "IRIS Toolbox"). This specific version of the IRIS toolbox is included in the repository.

## Disclaimer(s) ##

This model does not necessarily reflect the views of the Reserve Bank of New Zealand. Due to historical data revisions, the results from this model may differ slightly from those published in the working paper.




## Contact details ##

Created by: Michael Kirker

Email: <mkirker@uchicago.edu>

Website: [http://michaelkirker.net](http://michaelkirker.net "http://michaelkirker.net")

Git repository: [https://github.com/michaelkirker/Time-Varying-Natural-Rates]("https://github.com/michaelkirker/Time-Varying-Natural-Rates")


## Repository structure ##

* /code/
	* Folder containing functions required to run Bayesian estimation of the model (including IRIS Toolbox).
* /input/
	* Contains priors, raw data, and model file
* /output/ 
	* Folder containing output from Bayesian estimation.
* /temp/ 
	* Folder containing temporary files created by the model.
* batch.m
	* Batch file that executes the model code.




## How to use this code ##


The entire model can be run using the `batch.m` file. Each part of this batch file can be run independently if you have already run the previous sections. 


Within the input folder is specified the data to use in the estimation, the model structure, and the priors to use in the Bayesian estimation.

The first section of the `batch.m` file reads in the raw data from the excel spreadsheet, transforms the data to match the measurement variables in the model, and then saves down the data in an IRIS structure for use in the estimation.

The second section of the `batch.m` files conducts the Bayesian estimation of the model.

The final section of the `batch.m` file plots some of the results of the estimation in graph form.

## Background on this code ##

This code is designed to run in version 7 or the IRIS toolbox. Since version 7, there have been a number of (minor) structural changes to how the toolbox works. As a result, the model file will not run in its current form in the latest version of the toolbox. Therefore, I have included version 7 of the IRIS toolbox in this repository so the code can be run.

The more recent versions of the IRIS toolbox represent a significant improvement over version 7. One of the biggest changes is that Bayesian estimation of a model can now be carried out using inbuilt functions rather than having to supply your own Bayesian estimation code (as is done in this repository). Adapting the model file in this repository to run in the latest toolbox should be relatively straight forward to anyone who has read the IRIS User Guide. I believe the major change that would be required is updating the section titles within the `.mod` file to match the new format. 

While the model in this repository is identical to the one used to produce the results in the Working Paper (DP2008/17), the data included in this repository is taken from a more recent vintage of the data. Therefore, historical revisions to the data will mean that the output of this code may differ slightly from the results found in the Working Paper. 


	

## IRIS Toolbox License ##

This repository includes an older version of the [IRIS toolbox](https://iristoolbox.codeplex.com/ "IRIS Toolbox"). The licensing details of the IRIS toolbox are as follows:


Copyright (c) 2007-2014, IRIS Solutions Team
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
