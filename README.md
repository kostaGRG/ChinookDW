# ChinookDW
## Intro
The purpose of this project is to present, organize and analyze sales of Melodica Media Corp. fostering informed decision-making within the organization. The data is drawn from the chinook database. The structure and organization of data is as follows:

## A) Data Warehouse Creation
We have successfully implemented a Data Warehouse with a Snowflake schema, leveraging an intermediate staging area. The Staging Area supports incremental loading and implements Slowly Changing Dimension (SCD) for historical customer data.

## B) SSIS Project
Our SSIS project encompasses packages for DW and Staging Area creation, incremental loading, and maintenance tasks. This Visual Studio solution facilitates seamless management of data flow within the BI pipeline. The pipeline includes incremental loading (delta loading) of new rows of the fact table.

## C) SSAS Tabular Model
The SSAS Tabular model is designed based on the DW, incorporating all relevant data. DAX measures and calculated columns have been strategically added to provide comprehensive insights.

## D) Power BI Report
A Power BI report has been developed for real-time sales analysis. This report establishes a live connection with the SSAS Tabular model, offering dynamic and interactive visualization capabilities. 
