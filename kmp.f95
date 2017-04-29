!Domenic Bianchi
!CIS 3190
!April 7, 2017
!This program prompts the user for a file containing a block of text and a string to search for within that text using the KMP algorithm
!***This program is based on the Python implementation by Keith Schwarz: http://www.keithschwarz.com/interesting/code/knuth-morris-pratt/KnuthMorrisPratt.python.html***

!This module contains all subroutines needed to run this program
module mySubroutines

    contains

        !This subroutine creates the "fail" table used for the KMP algorithm
        subroutine createTable(pattern, table)

            implicit none

            integer :: count, i, j
            character (len=:), allocatable, intent(inout) :: pattern
            integer, dimension(:), allocatable, intent(inout) :: table

            count = 2
            i = 1
            j = 0

            !Determine the table/fail value for each letter in the pattern
            do i = 1, len(pattern)

                j = i
                do
                   !If j is equal to zero, then there is no offset/fail value required. Therefore, just set the fail value to 0
                   if (j == 1) then
                        table(count) = 1
                        count = count + 1
                        exit
                    end if

                    !If a match is made, the fail value can be imcremented by one (based off the fail value of the previous character in the pattern)
                    if (pattern(table(j):table(j)) .eq. pattern(i:i)) then
                        table(count) = table(j) + 1
                        count = count + 1
                        exit
                    end if

                    !If neither if statement is true, restart the fail value counter
                    j = table(j)
                end do
            end do
        end subroutine createTable

        !This subroutine executes the string search using the KMP algorithm (fail table)
        subroutine kmpSearch(pattern, table, line)

            implicit none

            integer :: index, match, foundMatch
            character (len=:), allocatable, intent(inout) :: pattern
            character (len=:), allocatable, intent(inout) :: line
            integer, dimension(:), allocatable, intent(inout) :: table

            index = 1
            match = 0
            foundMatch = 0

            !Search the entire string
            do while (index + match < len(line))
                if (match+1 < len(pattern)+1) then

                    !If the character matches the character we are expecting (based on where in the pattern we have already matched characters with) increment the match index
                    if (line(index+match:index+match) == pattern(match+1:match+1)) then
                        match = match + 1

                        !If the match index is equal to the length of the pattern, that means we have matched the enitre pattern
                        if (match == len(pattern)) then
                            foundMatch = 1
                            write (*,*) 'Found match at index ', index-1
                        end if
                    !Look at the table to determine what index to check next
                    else

                        !If no match was made on the first letter of the pattern, then just increment the index counter by one and check again
                        if (match == 0) then
                            index = index + 1
                        !Check how many characters to skip ahead (the point of the KMP algorithm)
                        else
                            index = index + match + 1 - table(match+1)
                            match = table(match+1) - 1
                        end if
                    end if
                else

                    !If no match was made on the first letter of the pattern, then just increment the index counter by one and check again
                    if (match == 0) then
                        index = index + 1
                    !Check how many characters to skip ahead (the point of the KMP algorithm)
                    else
                        index = index + match + 1 - table(match+1)
                        match = table(match+1) - 1
                    end if
                end if
            end do

            if (foundMatch == 0) then
                write(*,*) 'No match found'
            end if
        end subroutine kmpSearch

        !This subroutine parses the file containing the body of text into a string variable
        subroutine readFile(line, fileName)

            implicit none

            integer :: size, status, firstTime
            character :: buffer
            character (len=:), allocatable, intent(inout) :: line
            character (len=100000), intent(in) :: fileName

            size = 0
            firstTime = 1

            open(unit = 42, file = fileName, action = "read", status = "old")

            !Parse the input character by character
            do
                read(42, "(A)", advance='no', iostat=status, size=size) buffer

                if (IS_IOSTAT_END(status)) exit

                if (firstTime == 1) then
                    firstTime = 0
                    line = trim(adjustl(buffer))
                !A space is also the same as a new line character when reading in the file; therefore if a new line character is found in the file, just add a space to the string variable
                else if (buffer .eq. " ") then
                    line = line // " "
                else
                    line = line // trim(adjustl(buffer))
                end if
            end do

            close(unit = 42)
        end subroutine readFile

end module mySubroutines

program kmp
    use mySubroutines

    implicit none

    real :: startTime, endTime
    character (len=:), allocatable :: line
    character (len=:), allocatable :: pattern
    integer, dimension(:), allocatable :: table
    character (len=100000) :: largeBuffer
    logical :: fileExists

    largeBuffer = ''

    do

        largeBuffer = ''

        !Prompt for file containing the text body
        write(*,*) 'Enter a file name that contains the text that will be searched: '
        read(*,*) largeBuffer 

        inquire(file=largeBuffer, exist=fileExists)

        if (.not. fileExists) then
            write(*,*) 'Could not open file.'
        else
            exit
        end if
    end do

    call readFile(line, largeBuffer)

    largeBuffer = ''

    !Prompt for search pattern
    write(*,*) 'Enter a string that you want to search for: '
    read(*,'(A)') largeBuffer

    pattern = trim(adjustl(largeBuffer))

    allocate(table(len(pattern)+1))
    table(1) = -1

    call cpu_time(startTime)

    call createTable(pattern, table)
    call kmpSearch(pattern, table, line)

    call cpu_time(endTime)

    !Calculate total execution time
    write(*,*) 'Total execution time in seconds: ', (endTime-startTime)

    deallocate(table)
    deallocate(line)
    deallocate(pattern)

end
