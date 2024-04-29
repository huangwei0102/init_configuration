import argparse
import os
import subprocess
import sys
import time
from multiprocessing import Array, Lock, Process, Value

import torch


class GPUGet:
    def __init__(self, min_gpu_number, max_gpu_number, time_interval, duration_hours):
        self.occupied_num = Value("i", 0)  # Shared variable to count occupied GPUs
        self.occupied_gpus = Array("i", [-1 for _ in range(8)])  # Shared array to store occupied gpu
        self.min_gpu_number = min_gpu_number
        self.max_gpu_number = max_gpu_number
        self.time_interval = time_interval
        self.duration_hours = duration_hours

    def get_gpu_mem(self, gpu_id):
        gpu_query = subprocess.check_output(["nvidia-smi", "--query-gpu=memory.used", "--format=csv,nounits,noheader"])
        gpu_memory = [int(x) for x in gpu_query.decode("utf-8").split("\n")[:-1]]
        return gpu_memory[gpu_id]

    def get_free_gpus(self) -> list:
        gpu_query = subprocess.check_output(["nvidia-smi", "--query-gpu=memory.used", "--format=csv,nounits,noheader"])
        gpu_memory = [int(x) for x in gpu_query.decode("utf-8").split("\n")[:-1]]
        free_gpus = [i for i, mem in enumerate(gpu_memory) if mem < 1000]
        return free_gpus

    def get_gpu_info(self):
        gpu_status = os.popen("nvidia-smi | grep %").read().split("|")[1:]
        gpu_dict = dict()
        for i in range(len(gpu_status) // 4):
            index = i * 4
            gpu_state = str(gpu_status[index].split("   ")[2].strip())
            gpu_power = int(gpu_status[index].split("   ")[-1].split("/")[0].split("W")[0].strip())
            gpu_memory = int(gpu_status[index + 1].split("/")[0].split("M")[0].strip())
            gpu_dict[i] = (gpu_state, gpu_power, gpu_memory)
        return gpu_dict

    def loop_monitor(self):
        available_gpus = []
        while True:
            gpu_dict = self.get_gpu_info()
            for i, (gpu_state, gpu_power, gpu_memory) in gpu_dict.items():
                # if gpu_state == "P8" and gpu_power <= 40 and gpu_memory <= 1000:  # 设置GPU选用条件，当前适配的是Nvidia-RTX3090
                if gpu_power <= 50 and gpu_memory <= 3000:
                    gpu_str = (
                        f"GPU/id: {i}, GPU/state: {gpu_state}, GPU/memory: {gpu_memory}MiB, GPU/power: {gpu_power}W\n "
                    )
                    sys.stdout.write(gpu_str)
                    sys.stdout.flush()
                    available_gpus.append(i)
            if len(available_gpus) >= self.min_gpu_number:
                return (
                    available_gpus
                    if len(available_gpus) <= self.max_gpu_number
                    else available_gpus[: self.max_gpu_number]
                )
            else:
                available_gpus = []
                time.sleep(self.time_interval)

    def occupy_gpu(self, gpu_id: int, lock, a_dim=50000):
        try:
            with lock:
                if self.occupied_num.value >= self.max_gpu_number:
                    print(f"Cannot occupy GPU {gpu_id}: number limit reached.")
                    return
                if self.get_gpu_mem(gpu_id) < 100:
                    a = torch.ones((a_dim, a_dim)).cuda(gpu_id)
                    self.occupied_gpus[self.occupied_num.value] = gpu_id
                    self.occupied_num.value += 1
                    print(f"Using GPU {gpu_id}, Total number of GPUs used: {self.occupied_num.value}")
                else:
                    print(f"Cannot occupy GPU {gpu_id}: insufficient memory.")
                    return

            start_time = time.time()
            duration_seconds = self.duration_hours * 3600
            while time.time() - start_time < duration_seconds:
                a = a @ a
                time.sleep(5)
            print(f"Finished using GPU {gpu_id} after {self.duration_hours} hours.")
        except Exception as e:
            print(f"Exception in occupy_gpu on GPU {gpu_id}: {str(e)}")

    def occupy_all_gpus(self, interval=10):
        print("Launching process to Training ...")
        lock = Lock()
        processes = []
        while self.occupied_num.value < self.max_gpu_number:
            free_gpus = self.get_free_gpus()
            will_occupied_num = min(self.max_gpu_number - self.occupied_num.value, len(free_gpus))
            for i in range(will_occupied_num):
                with lock:  # 加锁确保在启动进程前没有其他进程改变占用数量
                    if self.occupied_num.value < self.max_gpu_number:
                        p = Process(target=self.occupy_gpu, args=(free_gpus[i], lock))
                        p.start()
                        processes.append(p)
                    else:
                        break
            time.sleep(interval)  # enough time to occupy gpus and update nvidia-smi
            for p in processes:
                if not p.is_alive():
                    print(f"Process {p.pid} on GPU {free_gpus[i]} has stopped unexpectedly.")
        return processes, self.occupied_num, self.occupied_gpus

    def run_my_program(self, n, desired_script, processes):
        for p in processes:
            p.terminate()
        occupied_gpus_list = list(self.occupied_gpus[: self.occupied_num.value])
        cuda_visible_devices = ",".join(map(str, occupied_gpus_list))
        os.environ["CUDA_VISIBLE_DEVICES"] = cuda_visible_devices
        subprocess.run([desired_script, str(n)])


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Arguments for Occupy GPUs")
    parser.add_argument("--max_gpu_number", type=int, default=4, help="Max number of GPUs to occupy")
    parser.add_argument("--min_gpu_number", type=int, default=1, help="Minimal number of GPUs to execute script")
    parser.add_argument("--time_interval", type=int, default=10, help="How often to monitor GPU status, in seconds.")
    parser.add_argument("--duration_hours", type=int, default=24, help="Times to use GPU, in hours.")
    parser.add_argument("--spath", type=str, default="./train_lora.sh", help="the execute script path")
    args = parser.parse_args()

    max_gpu_number = args.max_gpu_number
    min_gpu_number = args.min_gpu_number
    time_interval = args.time_interval
    duration_hours = args.duration_hours
    desired_script = args.spath

    gpu_get = GPUGet(min_gpu_number, max_gpu_number, time_interval, duration_hours)

    processes, occupied_num, occupied_gpus = gpu_get.occupy_all_gpus(time_interval)

    time.sleep(10)

    # if occupied_num.value >= min_gpu_number:
    #     print("Enough GPUs occupied. Running script ...")
    #     gpu_get.run_my_program(max_gpu_number, desired_script, processes)
