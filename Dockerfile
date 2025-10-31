# Base image
FROM ubuntu:22.04

LABEL description="SLURM + OpenMPI Environment"

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && apt-get install -y \
	build-essential \
	slurm-wlm \
	slurmctld \
	slurmd \
	munge \
	openmpi-bin \
	libopenmpi-dev \
	python3 \
	python3-pip \
	sudo \
	vim \
	curl \
	less \
	&& apt-get clean

# Configure MUNGE (generate key manually)
RUN mkdir -p /etc/munge && \
	dd if=/dev/urandom bs=1 count=1024 of=/etc/munge/munge.key && \
	chown -R munge:munge /etc/munge && \
	chmod 400 /etc/munge/munge.key

# Create slurm user if it doesn't exist, and setup directories
RUN id -u slurm &>/dev/null || useradd -m slurm && \
	mkdir -p /var/spool/slurm /var/log/slurm && \
	chown -R slurm:slurm /var/spool/slurm /var/log/slurm

# Generate a minimal slurm.conf for single-node
RUN mkdir -p /etc/slurm && \
	echo "ClusterName=docker" > /etc/slurm/slurm.conf && \
	echo "SlurmctldHost=localhost" >> /etc/slurm/slurm.conf && \
	echo "MpiDefault=none" >> /etc/slurm/slurm.conf && \
	echo "ProctrackType=proctrack/pgid" >> /etc/slurm/slurm.conf && \
	echo "ReturnToService=2" >> /etc/slurm/slurm.conf && \
	echo "SlurmUser=slurm" >> /etc/slurm/slurm.conf && \
	echo "SlurmdUser=root" >> /etc/slurm/slurm.conf && \
	echo "StateSaveLocation=/var/spool/slurm" >> /etc/slurm/slurm.conf && \
	echo "SlurmdSpoolDir=/var/spool/slurm" >> /etc/slurm/slurm.conf && \
	echo "SwitchType=switch/none" >> /etc/slurm/slurm.conf && \
	echo "TaskPlugin=task/none" >> /etc/slurm/slurm.conf && \
	echo "SlurmctldPidFile=/var/run/slurmctld.pid" >> /etc/slurm/slurm.conf && \
	echo "SlurmdPidFile=/var/run/slurmd.pid" >> /etc/slurm/slurm.conf && \
	echo "SlurmdPort=7003" >> /etc/slurm/slurm.conf && \
	echo "SlurmctldPort=7002" >> /etc/slurm/slurm.conf && \
	echo "NodeName=localhost CPUs=4 RealMemory=4000 State=UNKNOWN" >> /etc/slurm/slurm.conf && \
	echo "PartitionName=debug Nodes=localhost Default=YES MaxTime=INFINITE State=UP" >> /etc/slurm/slurm.conf

# Expose SLURM ports
EXPOSE 6817 6818

# Start MUNGE + SLURM services and drop to bash
CMD /bin/bash -c "\
	export OMPI_ALLOW_RUN_AS_ROOT=1 && \
	export OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1 && \
	service munge start && \
	service slurmctld start || true && \
	service slurmd start && \
	echo 'SLURM + OpenMPI node ready!' && \
	exec bash"

