#!/usr/bin/env python3

__author__ = 'jpleino1'

import pympi
import os
import sys
import re

def main(elan_file_path):
    eaf = pympi.Elan.Eaf(elan_file_path)
    abspath = os.path.abspath(elan_file_path)
    abspath_to, full_filename = os.path.split(abspath)
    filename, file_ext = os.path.splitext(full_filename)

    trn_name = os.path.join(abspath_to, "text")
    utt2spk_name = os.path.join(abspath_to, "utt2spk")
    spk2utt_name = os.path.join(abspath_to, "spk2utt")
    segments_name = os.path.join(abspath_to, "segments")
    reco2file_name = os.path.join(abspath_to, "reco2file_and_channel")
    wav_basepath = "data/src/wavs"
    wav_name = os.path.join(abspath_to, "wav.scp")
    
    columns = []
    numbers = 4 # For zfill, e.g., utterance 34 becomes 0034

    with open(trn_name, 'w', encoding="utf-8") as trn,\
        open(utt2spk_name, 'w', encoding="utf-8") as utt2spk,\
        open(spk2utt_name, 'w', encoding="utf-8") as spk2utt,\
        open(segments_name, 'w', encoding="utf-8") as segments,\
        open(reco2file_name, 'w', encoding="utf-8") as reco2file,\
        open(wav_name, 'w', encoding="utf-8") as wavs:

        for tier in eaf.tiers:
            try:
                for start, end, word in eaf.get_annotation_data_for_tier(tier):
                    columns.append([start, end, word]) 
            except:
                print(tier)
        columns = sorted(columns, key=lambda column: column[0])

        for count, column in enumerate(columns):
            utterance = filename + "-" + str(count).zfill(numbers)
            line_s = [utterance, filename, str(column[0]/1000.0), str(column[1]/1000.0)]

            segments.write(" ".join(line_s) + "\n")
            utt2spk.write(utterance + " " + utterance + "\n")
            spk2utt.write(utterance + " " + utterance + "\n")
            line_t = column[2]
            # Bit over zealous (ge) OK but (=ge) is not
            line_t = re.sub(r'\([^)]*\)', '', line_t)
            line_t = line_t.lower()
            line_t = re.sub(r"[^\w ']", " ", line_t, flags=re.UNICODE)
            line_t = line_t.strip()
            line_t = re.sub(' +', ' ', line_t)
            trn.write(utterance + " " + line_t + " " + "\n")
        wavs.write(filename + " " + wav_basepath + "/" + filename + ".wav" + "\n")
        reco2file.write(filename + " " + filename + " A\n")

if __name__ == "__main__":
    main(sys.argv[1])
