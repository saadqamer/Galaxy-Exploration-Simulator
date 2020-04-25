ETF-GUI
=======

To modify the GUI structure:

Step 1: in build_project.bpr, set 

<Project_location></Project_location> 

as 

<Project_location>.</Project_location> 

so that it is consistent with 

<Generation_location>.</Generation_location>.

Step 2: type

>esbuilder build_project.bpr&

The above will bring up EiffelStudio's builder. 

esbuilder can be used to change etf_main_window_imp.e if new buttons or widgets are needed.

