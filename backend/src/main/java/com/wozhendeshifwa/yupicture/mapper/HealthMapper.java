package com.wozhendeshifwa.yupicture.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

/**
 * 通道探针：走真实的 MyBatis-Plus mapper 链路（SqlSessionFactory -> 连接池 -> 驱动）， 而不是只拿
 * DataSource 手搓一条连接——后者证明不了 ORM 这条缝是通的。
 */
@Mapper
public interface HealthMapper {

    @Select("SELECT 1")
    Integer ping();
}
