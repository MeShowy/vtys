package com.vtysodev.vtysodev.repository;

import com.vtysodev.vtysodev.model.Depo;
import com.vtysodev.vtysodev.model.Il;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface IlRepository extends JpaRepository<Il, Integer> {
    @Query(value = """
        SELECT * FROM public.il
    """, nativeQuery = true)
    List<Il> getIller();
}
