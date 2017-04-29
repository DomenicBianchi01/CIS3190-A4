--Domenic Bianchi
--CIS 3190
--April 7, 2017
--This program prompts the user for a file containing a block of text and a string to search for within that text using the KMP algorithm
--***This program is based on the Python implementation by Keith Schwarz: http://www.keithschwarz.com/interesting/code/knuth-morris-pratt/KnuthMorrisPratt.python.html***

with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.strings.unbounded; use Ada.strings.unbounded;
with Ada.strings.unbounded.text_io; use Ada.strings.unbounded.text_io;
with Ada.Calendar; use Ada.Calendar;

procedure kmp is

    fileName : unbounded_string;
    pattern : unbounded_string;
    fullText : unbounded_string;
    tempString : unbounded_string;
    type genericTable is array(Integer range <>) of integer;
    fp : file_type;
    startTime, endTime : Time;
    totalTime : Duration;

    --This procedure creates the "fail" table used for the KMP algorithm
    procedure createTable(table : in out genericTable; pattern : in out unbounded_string) is

        j, count : integer;

        begin

            --Initialize array
            for i in 1..length(pattern) loop
                table(i) := 0;
            end loop;

            count := 2;
            table(0) := -1;
            table(1) := -1;

            --Determine the table/fail value for each letter in the pattern
            for i in 1..length(pattern) loop
                j := i;
                loop
                    --If j is equal to one, then there is no offset/fail value required. Therefore, just set the fail value to 1
                    if (j = 1) then
                        table(count) := 1;
                        count := count + 1;
                        exit;
                    end if;

                    --If a match is made, the fail value can be imcremented by one (based off the fail value of the previous character in the pattern)
                    if (element(pattern,table(j)) = element(pattern,i)) then
                        table(count) := table(j) + 1;
                        count := count + 1;
                        exit;
                    end if;

                    --If neither if statement is true, restart the fail value counter
                    j := table(j);
                end loop;
            end loop;
    end createTable;

    --This procedure executes the string search using the KMP algorithm (fail table)
    procedure kmpSearch(table : in genericTable; pattern : in out unbounded_string) is

       index, match, foundMatch : integer;

        begin

            index := 1;
            match := 0;
            foundMatch := 0;

            --Search the entire string
            while (index + match < length(fullText)+1) loop
                if (match+1 < length(pattern)+1) then

                    --If the character matches the character we are expecting (based on where in the pattern we have already matched characters with) increment the match index
                    if (element(fullText,index + match) = element(pattern,match+1)) then
                        match := match + 1;

                        --If the match index is equal to the length of the pattern, that means we have matched the enitre pattern
                        if (match = length(pattern)) then
                            foundMatch := 1;
                            put("Found match at index ");
                            put(index-1); new_line;
                        end if;
                    --Look at the table to determine what index to check next
                    else
                        --If no match was made on the first letter of the pattern, then just increment the index counter by one and check again
                        if (match = 0) then
                            index := index + 1;
                        --Check how many characters to skip ahead (the point of the KMP algorithm)
                        else
                            index := index + match - table(match+1) + 1;
                            match := table(match+1) - 1;
                        end if;
                    end if;
                --Look at the table to determine what index to check next
                else
                    --If no match was made on the first letter of the pattern, then just increment the index counter by one and check again
                    if (match = 0) then
                        index := index + 1;
                    --Check how many characters to skip ahead (the point of the KMP algorithm)
                    else
                        index := index + match - table(match+1) + 1;
                        match := table(match+1) - 1;
                    end if;
                end if;
            end loop;

            if (foundMatch = 0) then
                put("No match found"); new_line;
            end if;
    end kmpSearch;

    --This procedure attempts to open the file name inputed by the user and reads the data into a string variables character by character.
    procedure readFile(fileName : in unbounded_string; fullText : in out unbounded_string) is

        begin

            open(fp, in_file, to_string(fileName));

            --Loop through each character of the file and add it and a space to the string variable
            while (not end_of_file(fp)) loop
                get_line(fp, tempString);
                fullText := fullText & tempString & " ";
            end loop;

            close(fp);

            --Remove any whitespace that may exist at the end of the string
            fullText := delete(fullText,length(fullText),length(fullText));

    end readFile;

    begin
        loop
            begin
                --Prompt user for file name and reprompt if the input is invalid
                put("Enter file name that contains the text that will be searched: ");
                get_line(fileName);

                readFile(fileName, fullText);

                --Prompt the user for the string (pattern) to search for
                put("Enter a string that you want to search for: ");
                get_line(pattern);

                startTime := Clock;

                declare
                    table : genericTable(0..length(pattern)+1);
                begin

                    createTable(table, pattern);
                    kmpSearch(table, pattern);

                    endTime := Clock;

                    --Calculate the total execution time
                    totalTime := (endTime - startTime) * 1000;

                    put("Total execution time in milliseconds: ");
                    put(Duration'Image(totalTime)); new_line;
                    return;
                end;
            exception
                when name_error =>
                    put("Could not open file."); new_line;
            end;
        end loop;
end kmp;
