# 매개변수, 기본값 환경설정
# DRAM 메모리 주소와 데이터 크기 상수를 정의

from dataclasses import dataclass

@dataclass
class MemoryMap:
    DRAM_ADDR_TOKENS: int = 0x0000_0000 #입력 토큰 주소 -> 하드웨어에서 Read
    DRAM_ADDR_MASK: int = 0x0000_2000 #마스크 주소 -> 하드웨어에서 Read(패딩처리된 곳을 참조하여 mask==0일 시 break)
    DRAM_ADDR_RESULT: int = 0x0000_4000 #결과 주소 -> 하드웨어가 완성된 결과를 Write 하는 위치

    SIZE_INT: int = 4 #정수 크기 4바이트
    SIZE_FLOAT: int = 4 #실수 크기 4바이트
