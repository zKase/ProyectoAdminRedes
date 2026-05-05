import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule, ConfigService } from '@nestjs/config';

@Module({
  imports: [
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        url: configService.get<string>('DATABASE_URL'),
        autoLoadEntities: true, // Escanea automáticamente las entidades registradas
        // IMPORTANTE: En producción usar migraciones. 'synchronize' es solo para desarrollo.
        synchronize: process.env.NODE_ENV !== 'production', 
      }),
    }),
  ],
})
export class DatabaseModule {}
