# normal functioning

    Code
      meanAgree(dat[, -1])
    Output
      $agree.pairwise
         Coder1  Coder2  N agree
      1   Carol Dolores 50  0.98
      2   Carol  Edward 50  0.98
      3   Carol    John 50  0.98
      4 Dolores  Edward 50  0.96
      5 Dolores    John 50  1.00
      6  Edward    John 50  1.00
      
      $meanagree
      [1] 0.9833333
      

---

    Code
      meanKappa(dat[, -1])
    Output
      $agree.pairwise
         Coder1  Coder2  N     kappa
      1   Carol Dolores 50 0.9690977
      2   Carol  Edward 50 0.9652053
      3   Carol    John 50 0.9651811
      4 Dolores  Edward 50 0.9402628
      5 Dolores    John 50 1.0000000
      6  Edward    John 50 1.0000000
      
      $meankappa
      [1] 0.9732911
      

