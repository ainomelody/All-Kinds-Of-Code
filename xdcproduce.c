#include <stdio.h>
#include <string.h>

//从后往前排序

typedef void (*processFunc)(char *, FILE *);
char switches[16][3] = {"U9", "U8", "R7", "R6", "R5", "V7", "V6", "V5", "U4",
						"V2", "U2", "T3", "T1", "R3", "P3", "P4"};
char leds[16][3] = {"T8", "V9", "R8", "T6", "T5", "T4", "U7", "U6", "V4", "U3", "V1", "R1", "P5", "U1", "R2", "P2"};
char anodes[8][3] = {"N6", "M6", "M3", "N5", "N2", "N4", "L1", "M1"};
char cathnodes[8][3] = {"M4", "L6", "M2", "K3", "L4", "L5", "N1", "L3"};	//从后往前为a-g+dp
char buttons[5][4] = {"T16", "R10", "F15", "V10", "E16"};

void switchesFunc(char *inst, FILE *fout);
void ledsFunc(char *inst, FILE *fout);
void anodesFunc(char *inst, FILE *fout);
void cathnodesFunc(char *inst, FILE *fout);
void buttonsFunc(char *inst, FILE *fout);

int main()
{
	FILE *fout, *fin;
	char line[40];
	processFunc func;
	
	fout = fopen("output.txt", "w");
	fin = fopen("input.txt", "r");
	while (!feof(fin))
	{
		fgets(line, 40, fin);

		if (line[strlen(line) - 1] == '\n')
			line[strlen(line) - 1] = '\0';
		if (!strcmp(line, ""))
			continue;
		
		if (!strcmp(line, "<switches>"))
			func = switchesFunc;
		else if (!strcmp(line, "<leds>"))
			func = ledsFunc;
		else if (!strcmp(line, "<anodes>"))
			func = anodesFunc;
		else if (!strcmp(line, "<cathnodes>"))
			func = cathnodesFunc;
		else if (!strcmp(line, "<buttons>"))
			func = buttonsFunc;
		else
			func(line, fout);
	}
	fclose(fin);
	fclose(fout);
	
	return 0;
}

void switchesFunc(char *inst, FILE *fout)
{
	int num;
	char name[20];
	int i, numOfItems = 1;
	static int curIndex = 0;
	char *brak;
	
	brak = strchr(inst, '[');
	if (brak)
	{
		*brak = 0;
		sscanf(brak + 1, "%d", &numOfItems);
	}

	if (sscanf(inst, "%d %s", &num, name))	//指定index
		curIndex = num;
	else
		strcpy(name, inst);
	if (numOfItems == 1)
	{
		fprintf(fout, "set_property PACKAGE_PIN %s [get_ports %s]\n", switches[curIndex++], name);
		fprintf(fout, "set_property IOSTANDARD LVCMOS33 [get_ports %s]\n", name);
	}
	else
		for (i = 0; i < numOfItems; i++)
		{
			fprintf(fout, "set_property PACKAGE_PIN %s [get_ports %s[%d]]\n", switches[curIndex++], name, i);
			fprintf(fout, "set_property IOSTANDARD LVCMOS33 [get_ports %s[%d]]\n", name, i);
		}
}

void ledsFunc(char *inst, FILE *fout)
{
	int num;
	char name[20];
	int i, numOfItems = 1;
	static int curIndex = 0;
	char *brak;
	
	brak = strchr(inst, '[');
	if (brak)
	{
		*brak = 0;
		sscanf(brak + 1, "%d", &numOfItems);
	}

	if (sscanf(inst, "%d %s", &num, name))	//指定index
		curIndex = num;
	else
		strcpy(name, inst);
	if (numOfItems == 1)
	{
		fprintf(fout, "set_property PACKAGE_PIN %s [get_ports %s]\n", leds[curIndex++], name);
		fprintf(fout, "set_property IOSTANDARD LVCMOS33 [get_ports %s]\n", name);
	}
	else
		for (i = 0; i < numOfItems; i++)
		{
			fprintf(fout, "set_property PACKAGE_PIN %s [get_ports %s[%d]]\n", leds[curIndex++], name, i);
			fprintf(fout, "set_property IOSTANDARD LVCMOS33 [get_ports %s[%d]]\n", name, i);
		}
}

void anodesFunc(char *inst, FILE *fout)
{
	int num;
	char name[20];
	int i, numOfItems = 1;
	static int curIndex = 0;
	char *brak;
	
	brak = strchr(inst, '[');
	if (brak)
	{
		*brak = 0;
		sscanf(brak + 1, "%d", &numOfItems);
	}

	if (sscanf(inst, "%d %s", &num, name))	//指定index
		curIndex = num;
	else
		strcpy(name, inst);
	if (numOfItems == 1)
	{
		fprintf(fout, "set_property PACKAGE_PIN %s [get_ports %s]\n", anodes[curIndex++], name);
		fprintf(fout, "set_property IOSTANDARD LVCMOS33 [get_ports %s]\n", name);
	}
	else
		for (i = 0; i < numOfItems; i++)
		{
			fprintf(fout, "set_property PACKAGE_PIN %s [get_ports %s[%d]]\n", anodes[curIndex++], name, i);
			fprintf(fout, "set_property IOSTANDARD LVCMOS33 [get_ports %s[%d]]\n", name, i);
		}
}

void cathnodesFunc(char *inst, FILE *fout)
{
	int num;
	char name[20];
	int i, numOfItems = 1;
	static int curIndex = 0;
	char *brak;
	
	brak = strchr(inst, '[');
	if (brak)
	{
		*brak = 0;
		sscanf(brak + 1, "%d", &numOfItems);
	}

	if (sscanf(inst, "%d %s", &num, name))	//指定index
		curIndex = num;
	else
		strcpy(name, inst);
	if (numOfItems == 1)
	{
		fprintf(fout, "set_property PACKAGE_PIN %s [get_ports %s]\n", cathnodes[curIndex++], name);
		fprintf(fout, "set_property IOSTANDARD LVCMOS33 [get_ports %s]\n", name);
	}
	else
		for (i = 0; i < numOfItems; i++)
		{
			fprintf(fout, "set_property PACKAGE_PIN %s [get_ports %s[%d]]\n", cathnodes[curIndex++], name, i);
			fprintf(fout, "set_property IOSTANDARD LVCMOS33 [get_ports %s[%d]]\n", name, i);
		}
}

void buttonsFunc(char *inst, FILE *fout)
{
	int num;
	char name[20];
	int i, numOfItems = 1;
	static int curIndex = 0;
	char *brak;
	
	brak = strchr(inst, '[');
	if (brak)
	{
		*brak = 0;
		sscanf(brak + 1, "%d", &numOfItems);
	}

	if (sscanf(inst, "%d %s", &num, name))	//指定index
		curIndex = num;
	else
		strcpy(name, inst);
	if (numOfItems == 1)
	{
		fprintf(fout, "set_property PACKAGE_PIN %s [get_ports %s]\n", buttons[curIndex++], name);
		fprintf(fout, "set_property IOSTANDARD LVCMOS33 [get_ports %s]\n", name);
	}
	else
		for (i = 0; i < numOfItems; i++)
		{
			fprintf(fout, "set_property PACKAGE_PIN %s [get_ports %s[%d]]\n", buttons[curIndex++], name, i);
			fprintf(fout, "set_property IOSTANDARD LVCMOS33 [get_ports %s[%d]]\n", name, i);
		}
}