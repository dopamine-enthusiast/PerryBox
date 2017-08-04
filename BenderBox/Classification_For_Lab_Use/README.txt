How to classify a cell as Type 1, Type 2, or Type 3 

1) Export from Igor to Matlab - make sure the cell exports to C:Data:Export
2) Run Import_and_Classify(Cell, plot_yes_or_no), where "Cell" is a string with an asterix after it.
    - plot_yes_or_no indicates whether the results should be displayed with the distributions.
ex. Import_and_Classify('071215-1*', 'yes')

Requirements: 
- Spiking has to be within the first 2.5 minutes
    - Currently set to only accept 300 ms pulse duration, as this provides the best comparison.
    - To allow > 300 ms pulses
        1) go into "AnalyzeCell.m" under "Functions" 
        2) change the 'no' to 'yes' for "include_long_sweeps"
- Sag/rebound sweeps must be within the first 5 minutes and be 120 ms duration 
    - In this version cannot select to remove some sweeps from analysis, but can do that in later versions of matlab. 
   


