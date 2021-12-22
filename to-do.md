## To do List for rest of project
(delete as items are completed- delete entire file once project is complete)

1. Figure out how to handle NAICs errors
  - Ask Devin how to handle construction codes, hard code them if possible and emit them from error output that way
  - Will need to loop through multiple NAICs to IMPLAN walk-throughs to catch older codes that are for some reason still in use
    - May need to implement 2012 to 2017 NAICs crosswalks as well
  
2. Code means to fix the many to many IMPLAN NAICs crosswalk results
  - Should be straight forwards, fingers crossed
  
3. Double check no NAICs code industries repair code- this will just have to be hard coded. Don't see a way around it

4. When are we going to run the DOE code that separates out money given to defense contracts with the DOE? We should probably put this step above the error
   checking steps as this will further reduce the data size of our output. 
   
5. Start looking into how to process the Grants data (previously we have only been working with Contract data)
  - Select needed data using simaler parameters to those used to filter contracts data- include DOE filtering here as well
  - Error check this data- it looks like it has different error outputs compared to the Contracts data use old code to help
  - Repair data- again using older code to help guide implementation of the new
  
6. Start looking at employment data
  - Is this all stuff to be hard coded? Documentation will be rough, take extensive notes
  
7. Final steps will be making sure all outputs are ready for IMPLAN- do we want to provide the file schemas to run the final code bits?

8. Go through and re-outline the documentation, make sure to go over old notes to ensure nothing tricky or different was left out of the documentation
  - Readme file should be finalized first, and documentation structured off of it for a start
  
9. Finalize documentation repo and add in html links etc

10. Get Devin and Tom to proof read, apply edits and get ready for publishing. 

