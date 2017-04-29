//Domenic Bianchi
//CIS 3190
//April 7, 2017
//This program prompts the user for a file containing a block of text and a string to search for within that text using the KMP algorithm
//***This program is based on the Python implementation by Keith Schwarz: http://www.keithschwarz.com/interesting/code/knuth-morris-pratt/KnuthMorrisPratt.python.html***
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <sys/time.h>
#include <unistd.h>

//This function sets all the elements of a character array to null terminators
void clearArray(char string[], int length) {

	//Set entire array to null terminators
	for (int j = 0; j < length; j++) {

		string[j] = '\0';
	}
}

//This function prompts the user for a valid file name and search pattern and parses the inputs
void promptForFile(char fileName[], char ** pattern) {

	char * tempChar = NULL;
	int size = 0;
	int index2 = 0;
	int character = 0;

	//Prompt use for file name.
	do {
		printf("Enter a file name that contains the text that will be searched: ");
		scanf("%s", fileName);
		getchar();

		//If the file name given is invalid, prompt again
		if (access(fileName, F_OK) != -1) {

			break;
		}
		else {
			printf("Could not open file.\n");
		}
	} while (true);

	//Prompt for the string (pattern) to search for
	printf("Enter a string that you want to search for: ");

	//Parse the input character by character
	while ((character = getc(stdin)) != 0) {

		//Check for the return key. When found, stop parsing
		if (character == 10) {

			break;
		}

		//Realloc the pattern string for every new character
		if (size <= index2) {

			size = size + 50;
			tempChar = realloc(*pattern, size);

			//If the realloc fails, abort the the entire search
			if (tempChar == NULL) {

				free((*pattern));
				*pattern = NULL;
				break;
			}

			*pattern = tempChar;
		}

		(*pattern)[index2] = character;
		index2 = index2 + 1;
	}
	(*pattern)[index2] = '\0';
}

void loadFile(char fileName[], char ** line) {

	FILE * fp = NULL;
	char * tempChar = NULL;
	int character = 0;
	int size = 0;
	int index2 = 0;

	fp = fopen(fileName, "r");

	//Read in all the characters from the text file and realloc as neccessary
	while ((character = getc(fp)) != EOF) {

		if (size <= index2) {

			size = size + 50;
			tempChar = realloc(*line, size);

			//If relloc failed, abort the search
			if (tempChar == NULL) {

				free((*line));
				*line = NULL;
				break;
			}

			*line = tempChar;
		}

		//Add character to string; if the character is a new line character (10), convert it to a space (32)
		if (character == 10) {

			(*line)[index2] = 32;
		}
		else {

			(*line)[index2] = character;
		}

		index2 = index2 + 1;
	}

	(*line)[index2] = '\0';

	fclose(fp);
}

//This function creates the "fail" table used for the KMP algorithm
void createTable(char * pattern, int table[], int tableSize) {

	int count = 1;
	int j = 0;

	table[0] = -1;

	//Determine the table/fail value for each letter in the pattern
	for (int i = 0; i < strlen(pattern); i++) {

		j = i;

		while (true) {

			//If j is equal to zero, then there is no offset/fail value required. Therefore, just set the fail value to 0
			if (j == 0) {

				table[count] = 0;
				count = count + 1;

				break;
			}

			//If a match is made, the fail value can be imcremented by one (based off the fail value of the previous character in the pattern)
			if (pattern[table[j]] == pattern[i]) {

				table[count] = table[j] + 1;
				count = count + 1;
				break;
			}
			//If neither if statement is true, restart the fail value counter
			j = table[j];
		}
	}
}

//This function executes the string search using the KMP algorithm (fail table)
void kmpSearch(char pattern[], int table[], char line[]) {

	int index = 0;
	int match = 0;
	bool foundMatch = false;

	//Search the entire string
	while (index + match < strlen(line)) {

		//If the character matches the character we are expecting (based on where in the pattern we have already matched characters with) increment the match index
		if (line[index + match] == pattern[match]) {

			match = match + 1;

			//If the match index is equal to the length of the pattern, that means we have matched the enitre pattern
			if (match == strlen(pattern)) {

				foundMatch = true;
				printf("Found match at index %d\n", index);
			}
		}
		//Look at the table to determine what index to check next
		else {
			//If no match was made on the first letter of the pattern, then just increment the index counter by one and check again
			if (match == 0) {

				index = index + 1;
			}
			//Check how many characters to skip ahead (the point of the KMP algorithm)
			else {

				index = index + match - table[match];
				match = table[match];
                        }
                }
        }

	if (foundMatch == false) {

		printf("No match found\n");
	}
}

int main(int argc, char * argv[]) {

	char * line = NULL;
	int * table = NULL;
	char * pattern = NULL;
	char fileName[500];
	struct timeval startTime, endTime;

	clearArray(fileName, 500);

	promptForFile(fileName, &pattern);
	loadFile(fileName, &line);

	//Save start time
	gettimeofday(&startTime, NULL);

	//The last +1 byte is room for a null terminator
	table = malloc((sizeof(int)*(strlen(pattern)+1))+1);

	//If the malloc fails, abort the search
	if (table == NULL)  {

		free(table);
	}

	createTable(pattern, table, strlen(pattern));
	kmpSearch(pattern, table, line);

	//Save end time
	gettimeofday(&endTime, NULL);

	//Calculate total execution time
	printf("Total execution time in seconds: %f\n",  (double) (endTime.tv_usec - startTime.tv_usec) / 1000000 + (double) (endTime.tv_sec - startTime.tv_sec));

	free(pattern);
	free(table);
	free(line);

	return 0;
}
