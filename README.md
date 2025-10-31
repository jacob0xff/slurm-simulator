# slurs-simulator
A Docker slurp simulator with single and multi-node support for testing &amp; experimentation.

## Dockerfile
This dockerfile creates an image of slurm with openmp on a linux host. Feel free to adjust as needed.

To build image run:
```docker build -t slurmsim .```

## Cluster
To run the container environment as a cluster use the docker compose file.

```docker compose up -d```

Then to attach to the controller:

```docker exec -it slurm-controller bash```

Here you can work on slurm tasks for example:

```sinfo```

You can also check for OpenMP for distributed compute, but in the current state it runs as root so you may need to tweak the compose or run commands with 
```--allow-run-as-root```


Example

```bash
#!/bin/bash
echo "Creating basic mpi C source file."
cat <<EOF > /tmp/mpi_hello.c
#include <mpi.h>
#include <stdio.h>

int main(int argc, char** argv) {
    MPI_Init(&argc, &argv);
    int world_size, world_rank;
    MPI_Comm_size(MPI_COMM_WORLD, &world_size);
    MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);
    printf("Hello from rank %d of %d\\n", world_rank, world_size);
    MPI_Finalize();
    return 0;
}
EOF

echo "Compiling MPI X sample"
mpicc /tmp/mpi_hello.c -o /tmp/mpi_hello

echo "Running MPI C sample"
mpirun --allow-run-as-root -np 4 /tmp/mpi_hello

```

To add more nodes simply copy the compute1 node N times to your liking.



### Slurm .conf
```/slurm/slurm.conf``` holds the basic configurations of the slurm environment. Adjust as needed.
