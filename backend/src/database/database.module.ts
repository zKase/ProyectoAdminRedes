import { Module } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';

@Module({
  imports: [
    TypeOrmModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => {
        const databaseUrl = configService.get<string>('DATABASE_URL');
        const sslEnabled = (configService.get<string>('DB_SSL') ?? 'false') === 'true';

        return {
          type: 'postgres',
          url: databaseUrl,
          host: databaseUrl ? undefined : configService.get<string>('DB_HOST', 'localhost'),
          port: databaseUrl ? undefined : Number(configService.get<string>('DB_PORT', '5432')),
          username: databaseUrl ? undefined : configService.get<string>('DB_USERNAME', 'postgres'),
          password: databaseUrl ? undefined : configService.get<string>('DB_PASSWORD', 'contrasegura'),
          database: databaseUrl ? undefined : configService.get<string>('DB_NAME', 'proyecto_db'),
          autoLoadEntities: true,
          synchronize: (configService.get<string>('DB_SYNCHRONIZE') ?? 'true') === 'true',
          logging: (configService.get<string>('DB_LOGGING') ?? 'false') === 'true',
          ssl: sslEnabled ? { rejectUnauthorized: false } : false,
        };
      },
    }),
  ],
})
export class DatabaseModule {}
