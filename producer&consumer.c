#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <semaphore.h>
#define M 500
int main()
{
	sem_t *producer = sem_open("producer", O_CREAT, 0644, 10);
	sem_t *consumer = sem_open("consumer", O_CREAT, 0644, 0);
	sem_t *mutex = sem_open("mutex", O_CREAT, 0664, 1);
	int isFather = 1;
	int i, num;
	for (i = 0; i < 3; i++)
		isFather = isFather && fork();
	
	if (isFather)	//producer
	{
		for (i = 0; i <= M; i++)
		{
			FILE *fout = fopen("buf", "ab");
			sem_wait(producer);
			sem_wait(mutex);
			fwrite(&i, sizeof(int), 1, fout);
			fflush(fout);
			fclose(fout);
			sem_post(consumer);
			sem_post(mutex);
		}
		wait(NULL);
		
	}
	else		//consumer
	{	
		i = 0;
		while (i <= M)
		{
			int arr[10];
			int count;

			FILE *fin = fopen("buf", "rb");
			if (fin == NULL)
				continue;
			sem_wait(consumer);
			sem_wait(mutex);
			count = fread(arr, sizeof(int), 10, fin);
			if (!count)
			{
				sem_post(mutex);
				if (feof(fin))
					break;
				fclose(fin);				
				continue;
			}
			fclose(fin);
			fin = fopen("buf", "wb");
			fwrite(&arr[1], sizeof(int), count - 1, fin);
			fclose(fin);
			sem_post(producer);
			printf("%d: %d\n", getpid(), i = arr[0]);
			fflush(stdout);
			if (i == M)
			{
				int j;
				
				for (j = 0; j < 10; j++)
					sem_post(consumer);	
			}
			sem_post(mutex);
		}
	}
	sem_unlink("producer");
	sem_unlink("consumer");
	sem_unlink("mutex");
	return 0;
}
