SELECT
  AVG(BigSub.N) AS N_Obs,
  AVG(BigSub.NT) AS N_Treatment_Obs,
  COUNT(DISTINCT BigSub.networkid) AS N_Clusters,
  SUM(BigSub.treatment) AS N_Treatment_Clusters,
  
  AVG(BigSub.alpha_hat) AS alpha_hat,
  AVG(BigSub.beta_hat) AS beta_hat,
  
  SQRT( SUM( 1/( (NT*(N-NT))^2 ) * ( ((N*treatment) - NT)^2 )  * ( uhat_sum_squared  )  ) ) AS CRSE_beta_hat,
  AVG(beta_hat) / SQRT( SUM( 1/( (NT*(N-NT))^2 ) * ( ((N*treatment) - NT)^2 )  * ( uhat_sum_squared  )  ) ) AS CR_t_stat
  
FROM
  (
    SELECT
      AVG(MergedAndFitted.N) AS N,
      AVG(MergedAndFitted.NT) AS NT,
      MergedAndFitted.networkid AS networkid,
      AVG(MergedAndFitted.treatment) AS treatment,
      SUM(uhat) AS uhat_sum,
      (SUM(uhat))^2 AS uhat_sum_squared,
      AVG(alpha_hat) AS alpha_hat,
      AVG(beta_hat) AS beta_hat
    FROM
      (
        SELECT
          Merged.mykey AS mykey,
          Merged.outcomevec AS y,
          Merged.alpha_hat + Merged.beta_hat*Merged.treatmentvec AS yhat,
          Merged.outcomevec - Merged.alpha_hat - Merged.beta_hat*Merged.treatmentvec AS uhat,
          Merged.treatmentvec AS treatment,
          Merged.networkid AS networkid,
          Merged.N AS N,
          Merged.NT AS NT,
          Merged.alpha_hat AS alpha_hat,
          Merged.beta_hat AS beta_hat
        FROM
          (
            SELECT
              *
            FROM
              (
                (
                  SELECT
                    *
                  FROM temp.mdf_for_clusterSE
                ) tmfc
                CROSS JOIN
                (
                  SELECT
                    REGR_INTERCEPT(tmfc.outcomevec, tmfc.treatmentvec) AS alpha_hat,
                    REGR_SLOPE(tmfc.outcomevec, tmfc.treatmentvec) AS beta_hat,
                    REGR_COUNT(tmfc.outcomevec, tmfc.treatmentvec) AS N,
                    SUM(tmfc.treatmentvec) AS NT
                  FROM temp.mdf_for_clusterSE tmfc
                ) SS
              ) CJd
          ) Merged
      ) MergedAndFitted
    GROUP BY networkid
  ) BigSub